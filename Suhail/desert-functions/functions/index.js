/**
 * index.js — Desert App Cloud Functions
 */

const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const axios = require("axios");

initializeApp();

const db = getFirestore();

// WhatsApp server URL
const WHATSAPP_SERVER = "https://suhailwhatsapp-production.up.railway.app";

// WhatsApp API key — set via Firebase secret: WHATSAPP_API_KEY
const WHATSAPP_API_KEY = process.env.WHATSAPP_API_KEY;

// 35 minutes without any Firebase upload
const NO_RECENT_UPLOAD_LIMIT = 35 * 60;

// Debounce duration — wait 2 minutes after last upload before sending updated alert
const DEBOUNCE_SECONDS = 2 * 60;

// Max updated alert groups before auto-completing the trip
const MAX_UPDATED_ALERTS = 3;

// Collections to monitor — includes both production and dev
const MONITORED_COLLECTIONS = ["trips", "_trips_dev"];

// MARK: - Scheduled Trigger
exports.checkOverdueTrips = onSchedule({
    schedule: "every 5 minutes",
    secrets: ["WHATSAPP_API_KEY"]
}, async () => {
    const now = Date.now() / 1000;

    for (const collectionName of MONITORED_COLLECTIONS) {
        const snapshot = await db
            .collection(collectionName)
            .where("status.value", "in", ["active", "overdue"])
            .get();

        for (const doc of snapshot.docs) {
            const trip = doc.data();
            const tripId = doc.id;

            const statusObj = trip["status"] ?? {};
            const status = statusObj["value"];
            const tripInfo = trip["tripInfo"] ?? {};
            const location = trip["lastKnownLocation"] ?? {};

            const returnTime = tripInfo["returnTime"];
            const lastUploadTime = location["lastUploadTime"] ?? 0;

            if (!returnTime) continue;

            const returnTimePassed = now >= returnTime;
            const noRecentUploadFor35Min =
                lastUploadTime === 0 ||
                now - lastUploadTime >= NO_RECENT_UPLOAD_LIMIT;

            const alertAlreadySent = statusObj["alertSent"] === true;

            // Step 1: Mark trip as overdue immediately when return time passes
            if (returnTimePassed && status !== "overdue") {
                await db.collection(collectionName).doc(tripId).update({
                    "status.value": "overdue"
                });
                console.log(`[${collectionName}] Trip marked as overdue: ${tripId}`);
            }

            // Step 2: Send initial alert only if no recent upload for 35 minutes
            if (returnTimePassed && noRecentUploadFor35Min && !alertAlreadySent) {
                const alertSentSuccessfully = await sendAlert({
                    tripId,
                    trip,
                    type: "initial"
                });

                if (!alertSentSuccessfully) {
                    console.log(`[${collectionName}] Initial alert not marked as sent for ${tripId}`);
                    continue;
                }

                await db.collection(collectionName).doc(tripId).update({
                    "status.alertSent": true,
                    "status.alertSentAt": now,
                    "status.alertSentAtReadable": new Date().toLocaleString("ar-SA"),
                    "status.updatedAlertCount": 0,
                    "status.pendingAlertAt": 0,
                    "status.alertReason": "return_time_passed_no_recent_upload"
                });

                console.log(`[${collectionName}] Initial overdue alert sent for ${tripId}`);
            }

            // Step 3: Send debounced updated alert
            const pendingAlertAt = statusObj["pendingAlertAt"] ?? 0;
            const hasPendingAlert = pendingAlertAt > 0;
            const debounceElapsed = now - pendingAlertAt >= DEBOUNCE_SECONDS;
            const currentCount = statusObj["updatedAlertCount"] ?? 0;
            const maxReached = currentCount >= MAX_UPDATED_ALERTS;

            if (alertAlreadySent && hasPendingAlert && debounceElapsed && !maxReached) {
                const newCount = currentCount + 1;
                const shouldCompleteTrip = newCount >= MAX_UPDATED_ALERTS;

                const latestDoc = await db.collection(collectionName).doc(tripId).get();
                const latestTrip = latestDoc.data();

                const alertSentSuccessfully = await sendAlert({
                    tripId,
                    trip: latestTrip,
                    type: "updated"
                });

                if (!alertSentSuccessfully) {
                    console.log(`[${collectionName}] Updated alert failed for ${tripId}`);
                    continue;
                }

                const updates = {
                    "status.updatedAlertCount": newCount,
                    "status.pendingAlertAt": 0,
                    "status.updatedAlertSentAt": now,
                    "status.updatedAlertSentAtReadable": new Date().toLocaleString("ar-SA")
                };

                if (shouldCompleteTrip) {
                    updates["status.value"] = "completed";
                    updates["status.endedAt"] = now;
                    updates["status.endedAtReadable"] = new Date().toLocaleString("ar-SA");
                    console.log(`[${collectionName}] Trip auto-completed after ${MAX_UPDATED_ALERTS} updated alert groups — ${tripId}`);
                } else {
                    console.log(`[${collectionName}] Updated alert #${newCount} sent for ${tripId}`);
                }

                await db.collection(collectionName).doc(tripId).update(updates);
            }
        }
    }
});

// MARK: - Location Update Trigger (Production)
exports.onLocationUpdatedAfterOverdue = onDocumentUpdated({
    document: "trips/{tripId}",
    secrets: ["WHATSAPP_API_KEY"]
}, async (event) => {
    return handleLocationUpdate(event, "trips");
});

// MARK: - Location Update Trigger (Dev)
exports.onLocationUpdatedAfterOverdue_dev = onDocumentUpdated({
    document: "_trips_dev/{tripId}",
    secrets: ["WHATSAPP_API_KEY"]
}, async (event) => {
    return handleLocationUpdate(event, "_trips_dev");
});

// MARK: - Location Update Handler
async function handleLocationUpdate(event, collectionName) {
    const before = event.data.before.data();
    const after = event.data.after.data();

    const tripId = event.params.tripId;

    const beforeLocation = before["lastKnownLocation"] ?? {};
    const afterLocation = after["lastKnownLocation"] ?? {};
    const statusObj = after["status"] ?? {};
    const status = statusObj["value"];

    const oldUploadTime = beforeLocation["lastUploadTime"] ?? 0;
    const newUploadTime = afterLocation["lastUploadTime"] ?? 0;
    const newUploadArrived = newUploadTime > oldUploadTime;

    if (status !== "overdue") return;
    if (!newUploadArrived) return;
    if (statusObj["alertSent"] !== true) return;

    const currentCount = statusObj["updatedAlertCount"] ?? 0;
    if (currentCount >= MAX_UPDATED_ALERTS) return;

    const now = Date.now() / 1000;

    await db.collection(collectionName).doc(tripId).update({
        "status.pendingAlertAt": now
    });

    console.log(`[${collectionName}] Pending alert set for ${tripId} — will send after ${DEBOUNCE_SECONDS}s debounce`);
}

// MARK: - Send Alert Helper
async function sendAlert({ tripId, trip, type }) {
    const tripInfo = trip["tripInfo"] ?? {};
    const userInfo = trip["userInfo"] ?? {};
    const contacts = trip["emergencyContacts"] ?? [];
    const location = trip["lastKnownLocation"] ?? {};

    if (contacts.length === 0) {
        console.log(`No emergency contacts for ${tripId}`);
        return false;
    }

    const lat = location["lat"];
    const lng = location["lng"];
    const hasLocation = lat && lng && lat !== 0 && lng !== 0;

    const userName = userInfo["userName"] ?? "المستخدم";
    const tripStartTime = tripInfo["startTimeReadable"] ?? "غير معروف";
    const returnTime = tripInfo["returnTimeReadable"] ?? "غير معروف";
    const lastUpload = location["lastUploadTimeReadable"] ?? "غير معروف";
    const direction = location["direction"];
    const directionLine = direction ? `\nاتجاه الحركة:\n${direction}` : "";

    const mapsLink = hasLocation ? `https://maps.google.com/?q=${lat},${lng}` : null;
    const tripLink = `https://suhail-1.web.app/?id=${tripId}`;

    const batteryLevel = location["deviceBatteryLevel"];
    const batteryLine = (batteryLevel != null && batteryLevel >= 0)
        ? `\nنسبة بطارية المستخدم عند آخر تحديث:\n${batteryLevel}%`
        : "";

    const locationSection = hasLocation
        ? `📍 آخر موقع معروف:\n${mapsLink}\n\nآخر تحديث للموقع:\n${lastUpload}${directionLine}${batteryLine}`
        : `📍 الموقع:\nلم يتم تسجيل أي موقع لهذه الرحلة`;

    const message = type === "updated"
        ? `عزيزي وليّ أمر ${userName}،

وصلنا تحديث جديد لموقع ${userName} بعد تنبيه عدم العودة السابق.

${locationSection}

سنستمر في متابعة أي تحديثات، وسنقوم بإشعاركم فور وصول أي معلومات جديدة للموقع.

للاطلاع على تفاصيل الرحلة كاملة:
${tripLink}

— سهيل`
        : `عزيزي وليّ أمر ${userName}،

وصلك هذا التنبيه لأن ${userName} أضافك جهةَ اتصال للسلامة في تطبيق سهيل.

قبل انطلاق رحلته، سجّل ${userName} رحلته في التطبيق وحدّد وقتًا متوقعًا للعودة. ولم يصل أي تحديث جديد لموقعه بعد الوقت المحدد للعودة.

${locationSection}

قد يكون السبب انقطاع شبكة الاتصال أو نفاد شحن الجهاز. ننصح بمحاولة التواصل مع المسافر مباشرةً أولًا، وفي حال تعذّر الوصول إليه يمكن التواصل مع الجهات المختصة على الرقم 911.

للاطلاع على تفاصيل الرحلة كاملة:
${tripLink}

سنوافيك بأي تحديثات للموقع فور توفرها.

— سهيل`;

    let sentToAtLeastOneContact = false;

    for (const contact of contacts) {
        const contactPhone = contact["phone"]?.replace(/\D/g, "");
        if (!contactPhone) continue;

        try {
            const response = await axios.post(`${WHATSAPP_SERVER}/send`, {
                phone: contactPhone,
                message
            }, {
                headers: { "x-api-key": WHATSAPP_API_KEY }
            });

            if (response.data?.success === true) {
                sentToAtLeastOneContact = true;
                console.log(`WhatsApp sent to ${contactPhone} for trip ${tripId}`);
            } else {
                console.error(`WhatsApp failed for ${contactPhone}:`, response.data);
            }
        } catch (err) {
            console.error(`Failed to send WhatsApp to ${contactPhone}:`, err.message);
        }
    }

    return sentToAtLeastOneContact;
}

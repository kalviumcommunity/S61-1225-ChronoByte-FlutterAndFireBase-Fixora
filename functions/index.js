const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

async function sendToTokens(tokens, payload) {
  if (!tokens || tokens.length === 0) return;
  const res = await admin.messaging().sendMulticast({
    tokens: tokens,
    notification: payload.notification,
    data: payload.data || {},
  });

  // Remove invalid tokens
  const badTokens = [];
  res.responses.forEach((r, idx) => {
    if (!r.success) {
      const err = r.error;
      if (err && err.code && (err.code === 'messaging/invalid-registration-token' || err.code === 'messaging/registration-token-not-registered')) {
        badTokens.push(tokens[idx]);
      }
    }
  });
  return badTokens;
}

exports.onProblemCreate = functions.firestore
  .document('problems/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data() || {};
    const complaintId = data.complaintId || '';
    const category = data.category || '';
    const issue = data.issue || '';

    // Notify admins
    const adminsSnap = await admin.firestore().collection('users').where('role', '==', 'admin').get();
    let tokens = [];
    adminsSnap.forEach(doc => {
      const t = doc.get('fcmTokens') || [];
      tokens = tokens.concat(t);
    });

    tokens = Array.from(new Set(tokens));

    const payload = {
      notification: {
        title: 'New Complaint Submitted',
        body: `${complaintId}: ${issue} (${category})`,
      },
      data: {complaintId: complaintId},
    };

    const bad = await sendToTokens(tokens, payload);
    // Remove bad tokens from user docs
    if (bad && bad.length > 0) {
      for (const b of bad) {
        const usersWithToken = await admin.firestore().collection('users').where('fcmTokens', 'array-contains', b).get();
        usersWithToken.forEach(async (u) => {
          await u.ref.update({fcmTokens: admin.firestore.FieldValue.arrayRemove(b)});
        });
      }
    }

    return null;
  });

exports.onProblemUpdate = functions.firestore
  .document('problems/{docId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};

    const oldStatus = before.status || '';
    const newStatus = after.status || '';
    if (oldStatus === newStatus) return null;

    const complaintId = after.complaintId || '';
    const userId = after.userId || null;

    const payload = {
      notification: {
        title: 'Complaint Status Updated',
        body: `${complaintId}: ${oldStatus} → ${newStatus}`,
      },
      data: {complaintId: complaintId, newStatus: newStatus, oldStatus: oldStatus},
    };

    if (userId) {
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      const tokens = userDoc.get('fcmTokens') || [];
      const bad = await sendToTokens(tokens, payload);
      if (bad && bad.length > 0) {
        for (const b of bad) {
          await userDoc.ref.update({fcmTokens: admin.firestore.FieldValue.arrayRemove(b)});
        }
      }
    }

    return null;
  });

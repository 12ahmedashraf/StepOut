const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// ⚠️ Replace with your Gmail credentials or use a custom SMTP
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "your-email@gmail.com",       // Your email
    pass: "your-app-password",          // Gmail App Password
  },
});

exports.sendVerificationEmail = functions.firestore
  .document("email_verifications/{email}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const email = context.params.email;
    const code = data.code;

    const mailOptions = {
      from: "Step Out <your-email@gmail.com>",
      to: email,
      subject: "Your Step Out Verification Code",
      text: `Your verification code is: ${code}`,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log(`Verification email sent to ${email}`);
    } catch (error) {
      console.error("Error sending email:", error);
    }
  });

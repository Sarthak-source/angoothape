import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import {
  confirmForgot,
  forgotPassword,
  login,
  logout,
  resendOtp,
  verifyOtp,
} from '../controllers/auth.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

const loginLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
});

router.post('/login', loginLimit, asyncHandler(login));
router.post('/otp', loginLimit, asyncHandler(verifyOtp));
router.post('/resend', loginLimit, asyncHandler(resendOtp));
router.post('/logout', logout);
router.post('/forgot', loginLimit, asyncHandler(forgotPassword));
router.post('/forgot/confirm', loginLimit, asyncHandler(confirmForgot));

export default router;

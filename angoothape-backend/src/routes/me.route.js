import { Router } from 'express';
import {
  changePassword,
  getMe,
  resetDemo,
  updateMe,
  updatePreferences,
} from '../controllers/me.controller.js';
import { requireMfa } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.get('/me', asyncHandler(getMe));
router.patch('/me/preferences', asyncHandler(updatePreferences));
router.patch('/me', requireMfa, asyncHandler(updateMe));
router.post('/me/password', requireMfa, asyncHandler(changePassword));
router.post('/demo/reset', requireMfa, asyncHandler(resetDemo));
export default router;

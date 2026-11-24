import { Router } from 'express';
import {
  changePassword,
  getMe,
  resetDemo,
  updateMe,
  updatePreferences,
} from '../controllers/me.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.get('/me', asyncHandler(getMe));
router.patch('/me', asyncHandler(updateMe));
router.patch('/me/preferences', asyncHandler(updatePreferences));
router.post('/me/password', asyncHandler(changePassword));
router.post('/demo/reset', asyncHandler(resetDemo));
export default router;

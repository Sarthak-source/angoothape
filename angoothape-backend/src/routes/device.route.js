import { Router } from 'express';
import {
  deviceRequest,
  getDevice,
  patchDevice,
  testDevice,
} from '../controllers/device.controller.js';
import { requireMfa } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.get('/', asyncHandler(getDevice));
router.post('/test', requireMfa, asyncHandler(testDevice));
router.patch('/', requireMfa, asyncHandler(patchDevice));
router.post('/requests', requireMfa, asyncHandler(deviceRequest));
export default router;

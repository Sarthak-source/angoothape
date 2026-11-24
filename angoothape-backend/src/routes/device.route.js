import { Router } from 'express';
import {
  deviceRequest,
  getDevice,
  patchDevice,
  testDevice,
} from '../controllers/device.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.get('/', asyncHandler(getDevice));
router.post('/test', asyncHandler(testDevice));
router.patch('/', asyncHandler(patchDevice));
router.post('/requests', asyncHandler(deviceRequest));
export default router;

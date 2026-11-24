import { Router } from 'express';
import {
  approveApplication,
  createApplication,
  createEkyc,
} from '../controllers/join.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/ekyc', asyncHandler(createEkyc));
router.post('/', asyncHandler(createApplication));
router.post('/:id/approve', asyncHandler(approveApplication));
export default router;

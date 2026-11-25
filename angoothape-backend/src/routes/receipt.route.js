import { Router } from 'express';
import { createExport, receiptAction } from '../controllers/receipt.controller.js';
import { requireMfa } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/receipts/:ref/actions', requireMfa, asyncHandler(receiptAction));
router.post('/exports', requireMfa, asyncHandler(createExport));
export default router;

import { Router } from 'express';
import { createExport, receiptAction } from '../controllers/receipt.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/receipts/:ref/actions', asyncHandler(receiptAction));
router.post('/exports', asyncHandler(createExport));
export default router;

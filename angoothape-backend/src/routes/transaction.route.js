import { Router } from 'express';
import {
  checkTransaction,
  getTransaction,
  listTransactions,
} from '../controllers/transaction.controller.js';
import { requireMfa } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.get('/', asyncHandler(listTransactions));
router.get('/:ref', asyncHandler(getTransaction));
router.post('/:ref/check', requireMfa, asyncHandler(checkTransaction));
export default router;

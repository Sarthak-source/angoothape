import { Router } from 'express';
import {
  checkTransaction,
  getTransaction,
  listTransactions,
} from '../controllers/transaction.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.get('/', asyncHandler(listTransactions));
router.get('/:ref', asyncHandler(getTransaction));
router.post('/:ref/check', asyncHandler(checkTransaction));
export default router;

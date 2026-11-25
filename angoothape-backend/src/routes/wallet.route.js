import { Router } from 'express';
import {
  addAccount,
  createSettlement,
  topupWallet,
} from '../controllers/wallet.controller.js';
import { requireMfa } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/settlements', requireMfa, asyncHandler(createSettlement));
router.post('/accounts', requireMfa, asyncHandler(addAccount));
router.post('/wallet/topup', requireMfa, asyncHandler(topupWallet));
export default router;

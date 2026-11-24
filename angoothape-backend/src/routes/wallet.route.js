import { Router } from 'express';
import {
  addAccount,
  createSettlement,
  topupWallet,
} from '../controllers/wallet.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/settlements', asyncHandler(createSettlement));
router.post('/accounts', asyncHandler(addAccount));
router.post('/wallet/topup', asyncHandler(topupWallet));
export default router;

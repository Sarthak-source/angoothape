import { Router } from 'express';
import { submitAeps } from '../controllers/aeps.controller.js';
import { requireMfa } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/', requireMfa, asyncHandler(submitAeps));
export default router;

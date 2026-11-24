import { Router } from 'express';
import { submitAeps } from '../controllers/aeps.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/', asyncHandler(submitAeps));
export default router;

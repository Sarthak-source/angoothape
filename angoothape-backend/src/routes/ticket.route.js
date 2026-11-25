import { Router } from 'express';
import { createTicket } from '../controllers/ticket.controller.js';
import { requireMfa } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/', requireMfa, asyncHandler(createTicket));
export default router;

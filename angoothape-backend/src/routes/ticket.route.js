import { Router } from 'express';
import { createTicket } from '../controllers/ticket.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.post('/', asyncHandler(createTicket));
export default router;

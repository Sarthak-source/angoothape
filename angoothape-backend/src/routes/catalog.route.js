import { Router } from 'express';
import { getCatalog } from '../controllers/catalog.controller.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.get('/', asyncHandler(getCatalog));
export default router;

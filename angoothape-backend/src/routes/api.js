import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import authRouter from './auth.route.js';
import catalogRouter from './catalog.route.js';
import joinRouter from './join.route.js';
import meRouter from './me.route.js';
import transactionRouter from './transaction.route.js';
import aepsRouter from './aeps.route.js';
import walletRouter from './wallet.route.js';
import ticketRouter from './ticket.route.js';
import deviceRouter from './device.route.js';
import receiptRouter from './receipt.route.js';

const router = Router();

router.use('/auth', authRouter);
router.use('/catalog', catalogRouter);
router.use('/join', joinRouter);

const api = Router();
api.use(requireAuth);
api.use(meRouter);
api.use('/transactions', transactionRouter);
api.use('/aeps', aepsRouter);
api.use(walletRouter);
api.use('/tickets', ticketRouter);
api.use('/device', deviceRouter);
api.use(receiptRouter);
router.use('/api', api);

export default router;

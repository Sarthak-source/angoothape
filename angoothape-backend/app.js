import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { config } from './src/config.js';
import { authRouter } from './src/routes/auth.js';
import { sessionRouter } from './src/routes/session.js';
import { catalogRouter } from './src/routes/catalog.js';
import { joinRouter } from './src/routes/join.js';
import { errorHandler, notFound } from './src/middleware/error.js';

const app = express();

app.set('trust proxy', 1);
app.use(helmet());
app.use(
  cors({
    origin: (origin, cb) => {
      if (!origin || config.corsOrigins.includes(origin)) return cb(null, true);
      if (config.isDev && /^http:\/\/localhost:\d+$/.test(origin)) {
        return cb(null, true);
      }
      return cb(null, false);
    },
    credentials: true,
  }),
);
app.use(cookieParser());
app.use(express.json({ limit: '32kb' }));
app.use(morgan(config.isDev ? 'dev' : 'combined'));
app.use(
  rateLimit({
    windowMs: 60 * 1000,
    max: 120,
    standardHeaders: true,
    legacyHeaders: false,
  }),
);

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use('/auth', authRouter);
app.use('/catalog', catalogRouter);
app.use('/join', joinRouter);
app.use('/api', sessionRouter);
app.use(notFound);
app.use(errorHandler);

app.listen(config.port, () => {
  console.log(`angoothape API on :${config.port}`);
});

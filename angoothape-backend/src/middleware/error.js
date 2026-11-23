export function notFound(_req, res) {
  res.status(404).json({ error: 'not_found' });
}

export function errorHandler(err, _req, res, _next) {
  console.error(err);
  const status = err.status || 500;
  res.status(status).json({
    error: err.code || 'server_error',
    message: err.expose ? err.message : 'Something went wrong',
  });
}

export function fail(status, code, message) {
  const err = new Error(message);
  err.status = status;
  err.code = code;
  err.expose = true;
  return err;
}

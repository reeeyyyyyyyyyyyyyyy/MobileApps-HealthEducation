import { gooeyToast } from 'goey-toast';

export function useToast() {
  function promise(promiseFn, { loading, success, error }) {
    const toastId = gooeyToast.loading(loading, {
      preset: 'bouncy',
      duration: Infinity,
    });
    return promiseFn()
      .then((res) => {
        gooeyToast.dismiss(toastId);
        if (success) gooeyToast.success(success, { preset: 'bouncy', duration: 4000 });
        return res;
      })
      .catch((err) => {
        gooeyToast.dismiss(toastId);
        gooeyToast.error(error || err?.message || 'Terjadi kesalahan', {
          preset: 'bouncy',
          duration: 5000,
        });
        throw err;
      });
  }

  function success(msg) {
    gooeyToast.success(msg, { preset: 'bouncy', duration: 4000 });
  }

  function error(msg) {
    gooeyToast.error(msg, { preset: 'bouncy', duration: 5000 });
  }

  function warning(msg, opts) {
    gooeyToast.warning(msg, { preset: 'bouncy', duration: 6000, ...opts });
  }

  return { promise, success, error, warning };
}

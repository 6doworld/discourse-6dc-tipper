import { helper } from '@ember/component/helper';

export function increment(params) {
  return params[0] + 1;
}

export default helper(increment);
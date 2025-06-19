import Curves from '@ohos.curves';

/**
 * Default animation params.
 * @returns An AnimateParam, reading the arguments from app settings.
 * */
export function animationDefault() {
  let ap: AnimateParam = { curve: Curves.springMotion(0.36, 0.8) };
  return ap;
}

/**
 * Default Click effect.
 * @returns ClickEffect = { level: ClickEffectLevel.LIGHT }
 * */
export function clickEffectDefault() {
  let ce: ClickEffect = { level: ClickEffectLevel.LIGHT };
  return ce;
}
// SVGO configuration for Solar icon assets.
//
// Goal: shrink each SVG without breaking the visual behaviour the
// SolarIcon widget depends on. In particular:
//
// - viewBox must stay (SolarIcon relies on it for sizing).
// - fill="currentColor" must stay (SolarIcon paints via ColorFilter).
// - opacity="0.5" on duotone accent paths must stay (that's what makes
//   the duotone styles duotone).
// - IDs on <linearGradient> etc. must stay (any icons that use gradients
//   internally reference them by id).
//
// The default preset is enabled; only the risky plugins below are
// disabled or overridden.

export default {
  multipass: true,
  js2svg: {
    indent: 0,
    pretty: false,
  },
  plugins: [
    {
      name: 'preset-default',
      params: {
        overrides: {
          // Keep viewBox — SolarIcon uses it for scale.
          removeViewBox: false,
          // Keep IDs — some icons reference internal <linearGradient> ids.
          cleanupIds: false,
          // Do not merge paths — duotone icons have two paths with
          // different opacity values that must stay separate.
          mergePaths: false,
          // Do not touch stroke/fill declarations — currentColor + opacity
          // combinations are load-bearing.
          removeUselessStrokeAndFill: false,
          // Preserve the outer <svg> attribute order for stable diffs.
          sortAttrs: false,
          // Keep the `fill` attribute even when it looks redundant —
          // flutter_svg's parser relies on it in some duotone cases.
          removeUnknownsAndDefaults: {
            keepDataAttrs: false,
            keepAriaAttrs: false,
          },
        },
      },
    },
    // Trim path coordinates to 3 decimal places. Solar SVGs are drawn at
    // 24x24, so sub-thousandth precision is invisible at any render size.
    {
      name: 'convertPathData',
      params: {
        floatPrecision: 3,
        transformPrecision: 3,
      },
    },
    // Round transform matrices to 3 decimals as well.
    {
      name: 'cleanupNumericValues',
      params: {
        floatPrecision: 3,
      },
    },
  ],
};

// jscs:disable disallowQuotedKeysInObjects

import defaultPalette from '../palettes/defaultPalette';
import brightPalette from '../palettes/brightPalette';
import realisticPalette from '../palettes/realisticPalette';
import logger from '../utils/logger';

var palettes = {
  'default': defaultPalette,
  'bright': brightPalette,
  'realistic': realisticPalette,
};

//=========================================================
// Factory for palette creation
//=========================================================

export default class PaletteFactory {

  createPalette(id) {
    var palette = palettes[id];
    if (!palette) {
      throw new Error(`Unsupported palette "${id}"`);
    }
    logger.info(`Creating "${id}" palette`);
    return palette;
  }

}
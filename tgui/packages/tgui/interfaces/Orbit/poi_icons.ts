export type AvailableJob = keyof typeof POI_ICONS;

/** Icon map of POIs to fontawesome5 symbols. */
export const POI_ICONS = {
  Mech: 'car-battery',
  'Unidentified': 'question-circle',
} as const;

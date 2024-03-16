export type AvailableJob = keyof typeof JOB2ICON;

/** Icon map of jobs to their fontawesome5 (free) counterpart. */
export const JOB2ICON = {
  Mech: 'car-battery',
} as const;

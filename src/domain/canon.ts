export const BT_CANON = {
  product: 'BIGTUNE254',
  shortForm: 'BT',
  statement: 'Big up the music. Discover the people. Move the culture.',
  fanFlow: ['DISCOVER', 'LISTEN', 'FOLLOW', 'BIG UP', 'PARTICIPATE'],
  artistFlow: ['CLAIM', 'SHOWCASE', 'PUBLISH', 'GROW', 'UNDERSTAND', 'MONETIZE'],
  nav: ['Discover', 'Feed', 'Inbox', 'Profile'],
  interactions: ['BIG UP', 'BAD TUNE 🔥', 'ON REPEAT', 'PULL UP', 'FOLLOW', 'SHARE'],
} as const

export type BtInteraction = (typeof BT_CANON.interactions)[number]

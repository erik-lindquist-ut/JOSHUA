// Last Ten Yards — post set. Data + builders. Works in the browser and in node.
(function (root) {
  const W = 'https://upload.wikimedia.org/wikipedia/commons/thumb/';

  // path under commons/thumb, license, author
  const IMAGES = {
    cabSF:      { p: '3/3d/Tesla_Cybercab_-_San_Francisco_-_June_2026.jpg', lic: 'CC BY 4.0', by: '9yz' },
    cabInside:  { p: 'd/dc/Tesla_Cybercab_at_Santana_Row_interior_dllu.jpg', lic: 'CC BY-SA 4.0', by: 'Dllu', blur: [[0, 0, 100, 20]] },
    cabRear:    { p: '7/7a/Rear_of_the_Tesla_Cybercab.jpg', lic: 'CC BY 2.0', by: 'Steve Jurvetson', blur: [[0, 0, 100, 36]], plate: [51.6, 96.6] },
    cabFront:   { p: 'b/b8/Front_of_the_Tesla_Cybercab.jpg', lic: 'CC BY 2.0', by: 'Steve Jurvetson', blur: [[0, 0, 27, 72], [75, 0, 25, 72]] },
    cabDoors:   { p: '5/5c/Tesla_Cybercab_July_2025_%2854693064262%29.jpg', lic: 'CC BY 4.0', by: 'Steve Jurvetson', blur: [[0, 0, 100, 44]] },
    powerwall:  { p: '9/9c/TeslaPowerwall2.jpg', lic: 'CC0', by: 'Open Grid Scheduler', tall: true },
    powerwall2: { p: '6/6f/Tesla_Powerwall_in_Kenya.jpg', lic: 'CC BY 2.0', by: 'Herbie Pearthree', blur: [[55, 0, 45, 100]], tall: true },
    roof1:      { p: 'c/c5/Tesla_Solar_Roof-4.jpg', lic: 'CC0', by: 'Wikideas1' },
    roof2:      { p: 'f/f4/Tesla_Solar_Roof-6.jpg', lic: 'CC0', by: 'Wikideas1' },
    mega1:      { p: 'e/e6/Solar_landfill_with_Tesla_Megapacks_with_solar_canopies_4.webp', lic: 'CC0', by: 'Wikideas1' },
    mega2:      { p: 'd/db/Tesla_Megapack_set_of_4_with_solar_canopy.webp', lic: 'CC0', by: 'Wikideas1' },
    dish:       { p: 'd/d0/Starlink_Dish_20250111_101122.jpg', lic: 'CC BY 4.0', by: 'Ka23 13' },
    dishTruck:  { p: 'a/a3/Starlink_Flat_Panel_Dish_on_Roof_of_Truck_%2853371298608%29.jpg', lic: 'CC BY 2.0', by: 'Tony Webster' },
    satTown:    { p: 'b/b6/Starlink_%C3%BCber_dem_Rathaus_in_T%C3%BCbingen.jpg', lic: 'CC0', by: 'Dktue' },
    optimus:    { p: 'c/ca/Optimus_Tesla.jpg', lic: 'Public domain', by: 'Benjamin Ceci', tall: true },
    optimus2:   { p: 'c/c0/Latest_Tesla_Optimus_Humanoid_Robot.jpg', lic: 'CC BY 2.0', by: 'Steve Jurvetson', blur: [[0, 0, 34, 100], [64, 0, 36, 100]], tall: true },
    semi:       { p: '8/8a/Tesla_Semi_3.jpg', lic: 'Public domain', by: 'Korbitr' },
    semiCab:    { p: 'e/ea/Tesla_Semi_cockpit.jpg', lic: 'CC BY 2.0', by: 'Steve Jurvetson' },
    charger:    { p: '8/8f/Missoula_%28MT%2C_USA%29%2C_Tesla_Supercharger_--_2022_--_194228.jpg', lic: 'CC BY-SA 4.0', by: 'Dietmar Rabich', tall: true },
    charger2:   { p: '1/19/Tesla_-_Innsbruck_Supercharger-charging_point_top_PNr%C2%B00765.jpg', lic: 'CC BY-SA 4.0', by: 'D-Kuru', tall: true },
    falcon:     { p: 'b/b8/SES-10_Launch_-_world%27s_first_reflight_of_an_orbital_class_rocket_%2833361035200%29.jpg', lic: 'CC0', by: 'SpaceX' },
    falconLand: { p: '4/41/Falcon_9_first_stage_at_LZ-1%28two%29.jpg', lic: 'CC0', by: 'SpaceX Photos' },
    starship:   { p: 'b/b9/SpaceX_Starship_SN8_launch_as_viewed_from_South_Padre_Island.jpg', lic: 'CC BY-SA 4.0', by: 'Forest Katsch' },
    starFire:   { p: '4/4a/SpaceX_Starship_ignition_during_IFT-5.jpg', lic: 'CC BY 2.0', by: 'Steve Jurvetson', tall: true },
    truckMoab:  { p: '2/26/2024_Tesla_Cybertruck%2C_Moab_02.jpg', lic: 'CC0', by: 'A1C6' },
    truckDusk:  { p: 'f/f5/Foundation_series_Cybertruck_at_dusk_in_San_Jose_dllu.jpg', lic: 'CC BY-SA 4.0', by: 'Dllu' },
    midSign:    { p: '2/26/Midvale_CIty_Old_Town_sign.JPG', lic: 'CC BY-SA 4.0', by: 'An Errant Knight' },
    midCenter:  { p: 'c/cb/Midvale_Center_04.JPG', lic: 'CC BY-SA 4.0', by: 'An Errant Knight' },
    smog:       { p: 'a/a8/Salt_Lake_City_smog_haze_skyline_01.jpg', lic: 'CC BY-SA 4.0', by: 'Eltiempo10' },
    slcClear:   { p: '6/62/Salt_Lake_City_skyline%2C_August_2011.jpg', lic: 'CC BY 2.0', by: 'Garrett' },
    giga:       { p: '0/00/Gigafactory_Texas_Construction_North_Elevation_July_2021.jpg', lic: 'CC BY 4.0', by: 'Larry D. Moore' },
  };

  function imageUrl(k) {
    const p = IMAGES[k].p;
    return W + p + '/1280px-' + p.split('/')[2];
  }

  // Every post carries the company and the whole line, company first.
  const BASE_TAGS = ['#LastTenYards', '#Tesla', '#TeslaEnergy', '#Powerwall', '#Megapack', '#SolarRoof',
    '#Supercharger', '#Cybercab', '#Robotaxi', '#Robovan', '#Cybertruck', '#TeslaSemi', '#Optimus',
    '#TeslaBot', '#Starlink', '#SpaceX', '#Starship', '#Falcon9', '#Midvale', '#MidvaleUtah', '#AmericanDream'];

  const joshuaSays = (j) =>
    `Joshua says: Think, with compassion, about ${j.about}. Do it differently — with ${j.y}, or with ${j.z}.`;

  const photo = (img, eb, head, body) => ({ style: 'photo', img, eb, head, body });
  const novel = (img, head, about, y, z) => ({ style: 'novel', img, head, js: { about, y, z } });

  const POSTS = [
    { title: 'Powerwall', accent: 'teal', tags: ['#EnergyIndependence', '#HomeBattery', '#Backup'], hook: 'The lights stay on.', slides: [
      photo('powerwall', 'Powerwall', 'The lights stay on.', "Storm hits Midvale. The grid goes dark. Your house doesn't."),
      novel('powerwall2', 'Nobody on the block sits in the dark.', 'the family down the street when the power goes out', 'a Powerwall in every garage', 'one battery the whole block shares'),
      photo('powerwall', 'Stored sun', 'Sun by day. Power by night.', 'Charge from the roof. Run the house after dark. Pay the grid less.'),
      novel('powerwall2', 'Power for renters too.', 'who pays the most for power', 'batteries built for renters', 'a block that sells power back together'),
    ] },
    { title: 'Solar Roof', accent: 'violet', tags: ['#SolarPower', '#CleanEnergy', '#Roofing'], hook: 'Every roof is a power plant.', slides: [
      photo('roof1', 'Solar Roof', 'Every roof is a power plant.', 'It looks like a roof. It works like a power plant.'),
      novel('roof2', 'Fix the roof. Power the house.', 'the roofs that need fixing anyway', 'solar tiles', 'a street that re-roofs together'),
      photo('roof2', 'Midvale', 'What if all of Midvale did it?', 'Thousands of roofs. One quiet power plant. Made right here.'),
      novel('roof1', 'Built by our own crews.', 'the old roof on the house you grew up in', 'a Solar Roof', 'a crew from your own town'),
    ] },
    { title: 'Megapack', accent: 'lime', tags: ['#GridStorage', '#Microgrid', '#Substation'], hook: 'A power plant in a parking lot.', slides: [
      photo('mega1', 'Megapack', 'A power plant in a parking lot.', "Megapacks store the city's power and hand it back when it's needed."),
      novel('mega2', 'The grid holds.', 'the hottest day of summer, when the grid is close to breaking', 'a Megapack', 'a city that stores its own power'),
      photo('mega2', "Midvale's backup", 'Lights on for the whole city.', 'Sun on the roofs. Power in the packs. Midvale keeps running.'),
      novel('mega1', 'Nurses never lose power.', "the firefighters and nurses who can't lose power", 'backup at every station', 'one city battery that covers them all'),
    ] },
    { title: 'Starlink', accent: 'ice', tags: ['#Internet', '#Connectivity', '#FirstResponders'], hook: 'Online anywhere.', slides: [
      photo('dish', 'Starlink', 'Online anywhere.', 'A small dish. A sky full of satellites. Internet where there was none.'),
      novel('dishTruck', 'Homework, anywhere.', 'the kid doing homework with no Wi-Fi', 'a Starlink at the library', 'one on every school bus'),
      photo('satTown', 'Storm-proof', 'When lines go down, the sky stays up.', 'First responders stay connected when it matters most.'),
      novel('dish', 'Bars where there were none.', 'the crews who work where phones have no bars', 'a dish on every truck', 'a dish at every station'),
    ] },
    { title: 'Optimus', accent: 'coral', helix: true, tags: ['#Robotics', '#Pharmadash', '#Hospice'], hook: 'The hands.', slides: [
      photo('optimus', 'Strand A · Hands', 'The hands.', 'The prescription\'s last ten yards: curb to bedside.'),
      novel('optimus2', 'Curb to kitchen table.', 'patients stuck in bed', 'a person carrying it today', "Optimus when it's ready"),
      photo('optimus', 'Strand A · Home', 'Groceries up. Time back.', 'Stairs, laundry, dishes. Hours handed back to family.'),
      novel('optimus', 'Nobody alone.', 'neighbors living alone', 'a robot that helps', 'one that calls you'),
    ] },
    { title: 'Tesla Semi', accent: 'teal', helix: true, tags: ['#FireRescue', '#FirstResponders', '#OwnerOperator'], hook: 'The backbone.', slides: [
      photo('semi', 'Strand A · Machine', 'The backbone.', 'The Semi carries the heavy load: medicine, gear, freight.'),
      novel('semiCab', 'Fire rides on a Semi.', 'crews in old diesel rigs', 'an electric engine', 'heavy rescue on one frame'),
      photo('semi', 'Strand A · Medicine', 'Pharmacy on the backbone.', 'The Semi feeds branch pharmacies. Vans and cabs finish it.'),
      novel('semiCab', 'Owner. Operator.', 'drivers who want their own rig', 'their own Semi', 'a fleet behind them'),
    ] },
    { title: 'Supercharger', accent: 'gold', helix: true, tags: ['#EVCharging', '#RoadTrip', '#ShopLocal'], hook: 'Charge while you eat.', slides: [
      photo('charger', 'Strand A · Machine', 'Charge while you eat.', 'Plug in. Grab lunch. Leave full.'),
      novel('charger2', 'Range fear, gone.', 'drivers afraid of running out', 'a Midvale charger', 'one everywhere you stop'),
      photo('charger', 'Strand A · Main Street', 'Chargers bring customers.', 'Twenty minutes parked is twenty minutes spent in town.'),
      novel('charger2', 'Main Street wins.', 'the diner by the highway', 'chargers out front', 'a deal for every plug'),
    ] },
    { title: 'Falcon 9', accent: 'ice', helix: true, tags: ['#Rocket', '#Reusable', '#Satellite'], hook: 'One satellite. Fifty states.', slides: [
      photo('falcon', 'Strand A · Machine', 'Land it. Fly it again.', 'The rocket comes home. Nothing wasted.'),
      novel('falconLand', 'Try again.', 'the person who failed once', 'a second shot', 'someone to catch the landing'),
      photo('falcon', 'Strand A · Sky', 'One satellite. Fifty states.', 'Our own eye on every corridor. The fleet, always there.'),
      novel('falconLand', 'Always there.', 'riders stranded where towers stop', 'a Starlink on every roof', 'our satellite overhead'),
    ] },
    { title: 'Starship', accent: 'violet', helix: true, tags: ['#DreamBig', '#Space', '#Mars'], hook: 'Biggest rocket ever flown.', slides: [
      photo('starship', 'Strand A · Machine', 'Biggest rocket ever flown.', "Built to carry a city's worth of cargo."),
      novel('starFire', 'Dream bigger.', 'the dream you shelved', 'one step today', 'a crew that dreams with you'),
      photo('starship', 'Strand A · People', 'Welders launch rockets.', 'Every rocket is built by hands like yours.'),
      novel('starFire', 'People like you do this.', "kids who think it's not for them", 'a launch up close', 'a mentor'),
    ] },
    { title: 'Cybertruck', accent: 'coral', helix: true, tags: ['#Moab', '#Trades', '#BackupPower'], hook: 'Moab Saturday. Work Monday.', slides: [
      photo('truckMoab', 'Strand A · Machine', 'Moab Saturday. Work Monday.', 'Trail-ready. Job-site tough.'),
      novel('truckDusk', 'Power on the job.', 'crews with no outlet', 'a truck running tools', 'one that lights a house'),
      photo('truckMoab', 'Strand A · Home', 'Your truck is a generator.', 'Grid down? The truck runs the house.'),
      novel('truckDusk', 'Share the power.', 'families who lose power first', 'your truck', 'a neighbor who shares'),
    ] },
    { title: 'Midvale first', accent: 'lime', helix: true, tags: ['#Utah', '#SmallTown', '#SmartCity'], hook: 'Why Midvale first.', slides: [
      photo('midSign', 'Strand A · City', 'Why Midvale first.', 'Dead center of the valley. Ready now.'),
      novel('midCenter', 'A reason to stop.', 'the town everyone drives through', 'a reason to stop', 'a reason to stay'),
      photo('midCenter', 'Strand A · Grid', 'One city. Its own power.', 'Roofs make it. Packs store it. Cabs move it.'),
      novel('midSign', 'Nobody left out.', "the neighbor who can't afford it", 'shared power', 'jobs installing it'),
    ] },
    { title: 'Clean air', accent: 'ice', helix: true, tags: ['#Inversion', '#CleanAir', '#SaltLakeCity'], hook: 'See the mountains again.', slides: [
      photo('smog', 'Strand A · Air', 'See the mountains again.', 'Inversion season. Clean miles lift the gray.'),
      novel('slcClear', 'Let them breathe.', 'asthmatic kids on red-air days', 'electric buses', 'a robotaxi, not a second car'),
      photo('slcClear', 'Strand A · Sky', 'Clear skies every winter.', 'Every electric mile is one less puff of smoke.'),
      novel('smog', 'Back outside.', 'grandparents stuck inside on bad-air days', 'clean power', 'rides that burn nothing'),
    ] },
    { title: 'Jobs', accent: 'gold', helix: true, tags: ['#Jobs', '#Veterans', '#Hiring'], hook: 'The jobs are coming.', slides: [
      photo('giga', 'Strand A · Factory', 'The jobs are coming.', 'Factories, installs, fleets, robots. Why not you?'),
      novel('giga', 'Train for next.', 'workers whose jobs are ending', 'retraining', 'a company hiring them first'),
      photo('giga', 'Strand A · Midvale', 'First hires, right here.', 'Every roof, pack, and cab needs hands for the last ten yards.'),
      novel('giga', 'A new mission.', 'veterans who want a mission', 'a disciplined crew', 'work that serves the town'),
    ] },
    { title: 'The last ten yards', accent: 'coral', helix: true, tags: ['#FrontLine', '#ProudToBeAmerican', '#Service'], hook: 'The last ten yards.', slides: [
      photo('satTown', 'Strand A · Us', 'The last ten yards.', "Rockets to robots. It all ends at a door. That's us."),
      novel('dishTruck', 'We stay till it works.', 'the person at the door', 'care at the last step', 'crews that stay'),
      photo('satTown', 'Strand A · Front line', 'Nameless. Faceless. Front line.', 'Tip of the spear. The shield. The dream, delivered.'),
      novel('dishTruck', 'Midvale first. Then everyone.', 'who gets left out of the future', 'Midvale first', 'every town after'),
    ] },
  ];

  function tagsFor(p) {
    const seen = new Set();
    return [...BASE_TAGS, ...p.tags].filter((t) => !seen.has(t.toLowerCase()) && seen.add(t.toLowerCase()));
  }

  function captionFor(p) {
    const lines = p.slides.map((s, i) => `${i + 1}. ${s.head}`);
    const used = [...new Set(p.slides.map((s) => s.img))].map((k) => `${IMAGES[k].by} (${IMAGES[k].lic})`);
    return [
      p.hook, '',
      'Swipe →', ...lines, '',
      ...(p.helix ? ['Two strands, one helix: the machine, and the people it lifts.', ''] : []),
      'Everyone should dare to chase the American dream.', '',
      tagsFor(p).join(' '), '',
      'Photos via Wikimedia Commons: ' + [...new Set(used)].join('; ') + '.',
    ].join('\n');
  }

  const api = { POSTS, IMAGES, BASE_TAGS, joshuaSays, tagsFor, captionFor, imageUrl };
  if (typeof module !== 'undefined') module.exports = api;
  else root.LTY = api;
})(this);

import 'package:country_flags/country_flags.dart';

enum Country {
  afghanistan('AF', 93, 'Afghanistan'),
  albania('AL', 355, 'Albania'),
  algeria('DZ', 213, 'Algeria'),
  andorra('AD', 376, 'Andorra'),
  angola('AO', 244, 'Angola'),
  antarctica('AQ', 672, 'Antarctica'),
  argentina('AR', 54, 'Argentina'),
  armenia('AM', 374, 'Armenia'),
  aruba('AW', 297, 'Aruba'),
  australia('AU', 61, 'Australia'),
  austria('AT', 43, 'Austria'),
  azerbaijan('AZ', 994, 'Azerbaijan'),
  bahrain('BH', 973, 'Bahrain'),
  bangladesh('BD', 880, 'Bangladesh'),
  belarus('BY', 375, 'Belarus'),
  belgium('BE', 32, 'Belgium'),
  belize('BZ', 501, 'Belize'),
  benin('BJ', 229, 'Benin'),
  bhutan('BT', 975, 'Bhutan'),
  bolivia('BO', 591, 'Bolivia'),
  bosniaAndHerzegovina('BA', 387, 'Bosnia and Herzegovina'),
  botswana('BW', 267, 'Botswana'),
  brazil('BR', 55, 'Brazil'),
  britishIndianOceanTerritory('IO', 246, 'British Indian Ocean Territory'),
  brunei('BN', 673, 'Brunei'),
  bulgaria('BG', 359, 'Bulgaria'),
  burkinaFaso('BF', 226, 'Burkina Faso'),
  burundi('BI', 257, 'Burundi'),
  cambodia('KH', 855, 'Cambodia'),
  cameroon('CM', 237, 'Cameroon'),
  canada('CA', 1, 'Canada'),
  capeVerde('CV', 238, 'Cape Verde'),
  centralAfricanRepublic('CF', 236, 'Central African Republic'),
  chad('TD', 235, 'Chad'),
  chile('CL', 56, 'Chile'),
  china('CN', 86, 'China'),
  christmasIsland('CX', 61, 'Christmas Island'),
  cocosIslands('CC', 61, 'Cocos Islands'),
  colombia('CO', 57, 'Colombia'),
  comoros('KM', 269, 'Comoros'),
  cookIslands('CK', 682, 'Cook Islands'),
  costaRica('CR', 506, 'Costa Rica'),
  croatia('HR', 385, 'Croatia'),
  cuba('CU', 53, 'Cuba'),
  curacao('CW', 599, 'Curacao'),
  cyprus('CY', 357, 'Cyprus'),
  czechRepublic('CZ', 420, 'Czech Republic'),
  democraticRepublicOfTheCongo('CD', 243, 'Democratic Republic of the Congo'),
  denmark('DK', 45, 'Denmark'),
  djibouti('DJ', 253, 'Djibouti'),
  eastTimor('TL', 670, 'East Timor'),
  ecuador('EC', 593, 'Ecuador'),
  egypt('EG', 20, 'Egypt'),
  elSalvador('SV', 503, 'El Salvador'),
  equatorialGuinea('GQ', 240, 'Equatorial Guinea'),
  eritrea('ER', 291, 'Eritrea'),
  estonia('EE', 372, 'Estonia'),
  ethiopia('ET', 251, 'Ethiopia'),
  falklandIslands('FK', 500, 'Falkland Islands'),
  faroeIslands('FO', 298, 'Faroe Islands'),
  fiji('FJ', 679, 'Fiji'),
  finland('FI', 358, 'Finland'),
  france('FR', 33, 'France'),
  frenchPolynesia('PF', 689, 'French Polynesia'),
  gabon('GA', 241, 'Gabon'),
  gambia('GM', 220, 'Gambia'),
  georgia('GE', 995, 'Georgia'),
  germany('DE', 49, 'Germany'),
  ghana('GH', 233, 'Ghana'),
  gibraltar('GI', 350, 'Gibraltar'),
  greece('GR', 30, 'Greece'),
  greenland('GL', 299, 'Greenland'),
  guatemala('GT', 502, 'Guatemala'),
  guinea('GN', 224, 'Guinea'),
  guineaBissau('GW', 245, 'Guinea Bissau'),
  guyana('GY', 592, 'Guyana'),
  haiti('HT', 509, 'Haiti'),
  honduras('HN', 504, 'Honduras'),
  hongKong('HK', 852, 'Hong Kong'),
  hungary('HU', 36, 'Hungary'),
  iceland('IS', 354, 'Iceland'),
  india('IN', 91, 'India'),
  indonesia('ID', 62, 'Indonesia'),
  iran('IR', 98, 'Iran'),
  iraq('IQ', 964, 'Iraq'),
  ireland('IE', 353, 'Ireland'),
  israel('IL', 972, 'Israel'),
  italy('IT', 39, 'Italy'),
  ivoryCoast('CI', 225, 'Ivory Coast'),
  japan('JP', 81, 'Japan'),
  jordan('JO', 962, 'Jordan'),
  kazakhstan('KZ', 7, 'Kazakhstan'),
  kenya('KE', 254, 'Kenya'),
  kiribati('KI', 686, 'Kiribati'),
  kosovo('XK', 383, 'Kosovo'),
  kuwait('KW', 965, 'Kuwait'),
  kyrgyzstan('KG', 996, 'Kyrgyzstan'),
  laos('LA', 856, 'Laos'),
  latvia('LV', 371, 'Latvia'),
  lebanon('LB', 961, 'Lebanon'),
  lesotho('LS', 266, 'Lesotho'),
  liberia('LR', 231, 'Liberia'),
  libya('LY', 218, 'Libya'),
  liechtenstein('LI', 423, 'Liechtenstein'),
  lithuania('LT', 370, 'Lithuania'),
  luxembourg('LU', 352, 'Luxembourg'),
  macau('MO', 853, 'Macau'),
  macedonia('MK', 389, 'Macedonia'),
  madagascar('MG', 261, 'Madagascar'),
  malawi('MW', 265, 'Malawi'),
  malaysia('MY', 60, 'Malaysia'),
  maldives('MV', 960, 'Maldives'),
  mali('ML', 223, 'Mali'),
  malta('MT', 356, 'Malta'),
  marshallIslands('MH', 692, 'Marshall Islands'),
  mauritania('MR', 222, 'Mauritania'),
  mauritius('MU', 230, 'Mauritius'),
  mayotte('YT', 262, 'Mayotte'),
  mexico('MX', 52, 'Mexico'),
  micronesia('FM', 691, 'Micronesia'),
  moldova('MD', 373, 'Moldova'),
  monaco('MC', 377, 'Monaco'),
  mongolia('MN', 976, 'Mongolia'),
  montenegro('ME', 382, 'Montenegro'),
  morocco('MA', 212, 'Morocco'),
  mozambique('MZ', 258, 'Mozambique'),
  myanmar('MM', 95, 'Myanmar'),
  namibia('NA', 264, 'Namibia'),
  nauru('NR', 674, 'Nauru'),
  nepal('NP', 977, 'Nepal'),
  netherlands('NL', 31, 'Netherlands'),
  netherlandsAntilles('AN', 599, 'Netherlands Antilles'),
  newCaledonia('NC', 687, 'New Caledonia'),
  newZealand('NZ', 64, 'New Zealand'),
  nicaragua('NI', 505, 'Nicaragua'),
  niger('NE', 227, 'Niger'),
  nigeria('NG', 234, 'Nigeria'),
  niue('NU', 683, 'Niue'),
  northKorea('KP', 850, 'North Korea'),
  norway('NO', 47, 'Norway'),
  oman('OM', 968, 'Oman'),
  pakistan('PK', 92, 'Pakistan'),
  palau('PW', 680, 'Palau'),
  palestine('PS', 970, 'Palestine'),
  panama('PA', 507, 'Panama'),
  papuaNewGuinea('PG', 675, 'Papua New Guinea'),
  paraguay('PY', 595, 'Paraguay'),
  peru('PE', 51, 'Peru'),
  philippines('PH', 63, 'Philippines'),
  pitcairn('PN', 64, 'Pitcairn'),
  poland('PL', 48, 'Poland'),
  portugal('PT', 351, 'Portugal'),
  qatar('QA', 974, 'Qatar'),
  republicOfTheCongo('CG', 242, 'Republic of the Congo'),
  reunion('RE', 262, 'Reunion'),
  romania('RO', 40, 'Romania'),
  russia('RU', 7, 'Russia'),
  rwanda('RW', 250, 'Rwanda'),
  saintBarthelemy('BL', 590, 'Saint Barthelemy'),
  saintHelena('SH', 290, 'Saint Helena'),
  saintMartin('MF', 590, 'Saint Martin'),
  saintPierreAndMiquelon('PM', 508, 'Saint Pierre and Miquelon'),
  samoa('WS', 685, 'Samoa'),
  sanMarino('SM', 378, 'San Marino'),
  saoTomeAndPrincipe('ST', 239, 'Sao Tome and Principe'),
  saudiArabia('SA', 966, 'Saudi Arabia'),
  senegal('SN', 221, 'Senegal'),
  serbia('RS', 381, 'Serbia'),
  seychelles('SC', 248, 'Seychelles'),
  sierraLeone('SL', 232, 'Sierra Leone'),
  singapore('SG', 65, 'Singapore'),
  slovakia('SK', 421, 'Slovakia'),
  slovenia('SI', 386, 'Slovenia'),
  solomonIslands('SB', 677, 'Solomon Islands'),
  somalia('SO', 252, 'Somalia'),
  southAfrica('ZA', 27, 'South Africa'),
  southKorea('KR', 82, 'South Korea'),
  southSudan('SS', 211, 'South Sudan'),
  spain('ES', 34, 'Spain'),
  sriLanka('LK', 94, 'Sri Lanka'),
  sudan('SD', 249, 'Sudan'),
  suriname('SR', 597, 'Suriname'),
  svalbardAndJanMayen('SJ', 47, 'Svalbard and Jan Mayen'),
  swaziland('SZ', 268, 'Swaziland'),
  sweden('SE', 46, 'Sweden'),
  switzerland('CH', 41, 'Switzerland'),
  syria('SY', 963, 'Syria'),
  taiwan('TW', 886, 'Taiwan'),
  tajikistan('TJ', 992, 'Tajikistan'),
  tanzania('TZ', 255, 'Tanzania'),
  thailand('TH', 66, 'Thailand'),
  togo('TG', 228, 'Togo'),
  tokelau('TK', 690, 'Tokelau'),
  tonga('TO', 676, 'Tonga'),
  tunisia('TN', 216, 'Tunisia'),
  turkey('TR', 90, 'Turkey'),
  turkmenistan('TM', 993, 'Turkmenistan'),
  tuvalu('TV', 688, 'Tuvalu'),
  uganda('UG', 256, 'Uganda'),
  ukraine('UA', 380, 'Ukraine'),
  unitedArabEmirates('AE', 971, 'United Arab Emirates'),
  unitedKingdom('GB', 44, 'United Kingdom'),
  unitedStates('US', 1, 'United States'),
  uruguay('UY', 598, 'Uruguay'),
  uzbekistan('UZ', 998, 'Uzbekistan'),
  vanuatu('VU', 678, 'Vanuatu'),
  vatican('VA', 379, 'Vatican'),
  venezuela('VE', 58, 'Venezuela'),
  vietnam('VN', 84, 'Vietnam'),
  wallisAndFutuna('WF', 681, 'Wallis and Futuna'),
  westernSahara('EH', 212, 'Western Sahara'),
  yemen('YE', 967, 'Yemen'),
  zambia('ZM', 260, 'Zambia'),
  zimbabwe('ZW', 263, 'Zimbabwe');

  final String code;
  final int number;
  final String displayName;

  const Country(this.code, this.number, this.displayName);

  CountryFlag circleFlag(double width, double height) {
    return CountryFlag.fromCountryCode(
      code,
      width: width,
      height: height,
      shape: Circle(),
    );
  }

  CountryFlag rectangleFlag(double width, double height) {
    return CountryFlag.fromCountryCode(
      code,
      width: width,
      height: height,
      shape: Rectangle(),
    );
  }

  CountryFlag roundedFlag(double width, double height, double borderRadius) {
    return CountryFlag.fromCountryCode(
      code,
      width: width,
      height: height,
      shape: RoundedRectangle(borderRadius),
    );
  }

  static List<CountryFlag> listCircle(double width, double height) {
    List<CountryFlag> result = [];

    for (final country in values) {
      result.add(country.circleFlag(width, height));
    }

    return result;
  }

  static List<CountryFlag> listRectangle(double width, double height) {
    List<CountryFlag> result = [];

    for (final country in values) {
      result.add(country.rectangleFlag(width, height));
    }

    return result;
  }

  static List<CountryFlag> listRounded(
    double width,
    double height,
    double borderRadius,
  ) {
    List<CountryFlag> result = [];

    for (final country in values) {
      result.add(country.roundedFlag(width, height, borderRadius));
    }

    return result;
  }
}

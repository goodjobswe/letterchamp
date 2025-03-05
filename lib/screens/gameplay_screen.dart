import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';

/// A mapping from a letter to its list of expected stroke checkpoints.
/// Each letter is associated with one or more StrokeCheckpoints objects (one per stroke).
final Map<String, List<StrokeCheckpoints>> letterStrokePaths = {
  'A': [
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(136.0, 92.5), Offset(121.2, 130.9), Offset(106.3, 169.3), Offset(91.5, 207.7)],
      end: Offset(77, 243),
    ),
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(165.8, 92.5), Offset(180.7, 130.9), Offset(195.7, 169.3), Offset(210.6, 207.7)],
      end: Offset(222, 243),
    ),
    StrokeCheckpoints(
      start: Offset(97, 196),
      inBetween: [Offset(131.4, 196.6), Offset(167.8, 196.4)],
      end: Offset(207, 196),
    ),
  ],
  'a': [
    StrokeCheckpoints(
      start: Offset(213, 143),
      inBetween: [Offset(192.3, 123.1), Offset(167.5, 107.5), Offset(135.6, 101.4), Offset(105.9, 112.1), Offset(85.6, 131.9), Offset(76.7, 161.5), Offset(76.7, 196.7), Offset(94.0, 221.4), Offset(114.8, 241.7), Offset(146.2, 246.6), Offset(174.7, 238.1), Offset(198.0, 219.8)],
      end: Offset(213, 200),
    ),
    StrokeCheckpoints(
      start: Offset(213, 100),
      inBetween: [Offset(213, 137.0), Offset(213, 172.3), Offset(213, 207.7)],
      end: Offset(213, 246),
    ),
  ],
  'B': [
    StrokeCheckpoints(
      start: Offset(95, 58),
      inBetween: [Offset(95, 95.3), Offset(95, 132.2), Offset(95, 169.1), Offset(95, 206.1)],
      end: Offset(95, 242),
    ),
    StrokeCheckpoints(
      start: Offset(95, 58),
      inBetween: [Offset(132.4, 57.8), Offset(171.1, 58.3), Offset(199.3, 74.6), Offset(212.5, 103.5), Offset(196.1, 132.0), Offset(168.0, 146.4), Offset(130.5, 148.9)],
      end: Offset(95, 147),
    ),
    StrokeCheckpoints(
      start: Offset(161, 147),
      inBetween: [Offset(185.1, 157.3), Offset(207.8, 177.1), Offset(211.4, 209.9), Offset(192.7, 232.0), Offset(164.3, 243.0), Offset(130.9, 246.1)],
      end: Offset(95, 242),
    ),
  ],
  'b': [
    StrokeCheckpoints(
      start: Offset(84, 44),
      inBetween: [Offset(84, 86.1), Offset(84, 125.4), Offset(84, 164.6), Offset(84, 203.8)],
      end: Offset(84, 242),
    ),
    StrokeCheckpoints(
      start: Offset(84, 144),
      inBetween: [Offset(102.9, 127.0), Offset(128.3, 110.0), Offset(156.8, 101.6), Offset(187.7, 107.9), Offset(211.3, 124.8), Offset(220.8, 154.9), Offset(221.9, 187.5), Offset(206.5, 214.0), Offset(185.8, 235.3), Offset(156.3, 244.1), Offset(125.5, 238.8), Offset(105.9, 218.9)],
      end: Offset(84, 206),
    ),
  ],
  'C': [
    StrokeCheckpoints(
      start: Offset(227, 95),
      inBetween: [Offset(205.0, 74.2), Offset(176.9, 63.9), Offset(143.1, 59.4), Offset(109.2, 64.1), Offset(85.4, 82.1), Offset(65.9, 105.6), Offset(60.6, 138.2), Offset(56.9, 171.0), Offset(71.4, 197.4), Offset(89.4, 222.6), Offset(117.1, 236.6), Offset(148.9, 243.3), Offset(182.2, 239.7), Offset(209.3, 225.8)],
      end: Offset(227, 204),
    ),
  ],
  'c': [
    StrokeCheckpoints(
      start: Offset(212, 135),
      inBetween: [Offset(188.6, 111.3), Offset(156.9, 104.2), Offset(125.0, 109.4), Offset(99.2, 129.1), Offset(88.3, 159.3), Offset(89.2, 193.5), Offset(105.0, 221.9), Offset(130.8, 237.7), Offset(163.7, 245.0), Offset(193.4, 234.1)],
      end: Offset(212, 211),
    ),
  ],
  'D': [
    StrokeCheckpoints(
      start: Offset(80, 57),
      inBetween: [Offset(80, 95.1), Offset(80, 130.8), Offset(80, 166.4), Offset(80, 202.1)],
      end: Offset(80, 242),
    ),
    StrokeCheckpoints(
      start: Offset(80, 57),
      inBetween: [Offset(114.4, 53.6), Offset(150.1, 57.2), Offset(179.9, 70.5), Offset(207.0, 89.6), Offset(222.2, 117.7), Offset(227.8, 151.8), Offset(225.8, 188.1), Offset(206.8, 214.8), Offset(180.5, 232.2), Offset(150.0, 243.3), Offset(113.7, 246.1)],
      end: Offset(80, 242),
    ),
  ],
  'd': [
    StrokeCheckpoints(
      start: Offset(215, 147),
      inBetween: [Offset(191.6, 126.8), Offset(169.4, 106.4), Offset(138.1, 100.0), Offset(106.1, 107.2), Offset(84.7, 129.2), Offset(77.5, 162.3), Offset(78.6, 196.3), Offset(94.8, 224.1), Offset(120.3, 240.8), Offset(151.2, 246.9), Offset(178.2, 232.5), Offset(201.4, 214.4)],
      end: Offset(215, 196),
    ),
    StrokeCheckpoints(
      start: Offset(215, 44),
      inBetween: [Offset(215, 85.8), Offset(215, 125.1), Offset(215, 164.5), Offset(215, 203.9)],
      end: Offset(215, 242),
    ),
  ],
  'E': [
    StrokeCheckpoints(
      start: Offset(111, 56),
      inBetween: [Offset(111, 93.3), Offset(111, 129.4), Offset(111, 165.5), Offset(111, 201.6)],
      end: Offset(111, 245),
    ),
    StrokeCheckpoints(
      start: Offset(111, 56),
      inBetween: [Offset(155.1, 56)],
      end: Offset(197, 56),
    ),
    StrokeCheckpoints(
      start: Offset(111, 150),
      inBetween: [Offset(149.9, 150)],
      end: Offset(189, 150),
    ),
    StrokeCheckpoints(
      start: Offset(111, 245),
      inBetween: [Offset(154.3, 245)],
      end: Offset(197, 245),
    ),
  ],
  'e': [
    StrokeCheckpoints(
      start: Offset(87, 173),
      inBetween: [Offset(130.3, 173), Offset(173.6, 173)],
      end: Offset(217, 173),
    ),
    StrokeCheckpoints(
      start: Offset(217, 173),
      inBetween: [Offset(214.4, 136.6), Offset(193.3, 113.6), Offset(160.8, 104.2), Offset(123.7, 105.3), Offset(97.9, 124.0), Offset(85.8, 152.6), Offset(82.2, 187.4), Offset(96.2, 217.8), Offset(119.7, 237.7), Offset(153.5, 246.9), Offset(188.1, 239.4)],
      end: Offset(210, 216),
    ),
  ],
  'F': [
    StrokeCheckpoints(
      start: Offset(111, 56),
      inBetween: [Offset(111, 93.3), Offset(111, 129.4), Offset(111, 165.5), Offset(111, 201.6)],
      end: Offset(111, 245),
    ),
    StrokeCheckpoints(
      start: Offset(111, 56),
      inBetween: [Offset(155.1, 56)],
      end: Offset(197, 56),
    ),
    StrokeCheckpoints(
      start: Offset(111, 150),
      inBetween: [Offset(149.9, 150)],
      end: Offset(189, 150),
    ),
  ],
  'f': [
    StrokeCheckpoints(
      start: Offset(180, 38),
      inBetween: [Offset(151.0, 52.2), Offset(142.8, 85.6), Offset(142, 125.9), Offset(142, 163.3), Offset(142, 203.9)],
      end: Offset(142, 245),
    ),
    StrokeCheckpoints(
      start: Offset(117, 103),
      inBetween: [Offset(149.0, 103)],
      end: Offset(180, 103),
    ),
  ],
  'G': [
    StrokeCheckpoints(
      start: Offset(229, 99),
      inBetween: [Offset(203.5, 73.6), Offset(174.8, 60.2), Offset(140.0, 57.2), Offset(107.4, 65.0), Offset(85.6, 85.7), Offset(66.6, 110.3), Offset(62.4, 144.2), Offset(63.1, 179.5), Offset(78.5, 208.0), Offset(100.8, 228.8), Offset(130.8, 240.3), Offset(165.2, 245.0), Offset(195.7, 233.6), Offset(221.8, 215.6), Offset(233.4, 186.2)],
      end: Offset(240, 155),
    ),
    StrokeCheckpoints(
      start: Offset(154, 155),
      inBetween: [Offset(196.8, 155)],
      end: Offset(240, 155),
    ),
  ],
  'g': [
    StrokeCheckpoints(
      start: Offset(214, 144),
      inBetween: [Offset(197.6, 123.9), Offset(172.9, 106.9), Offset(141.1, 101.1), Offset(107.2, 106.3), Offset(87.6, 128.6), Offset(72.5, 156.0), Offset(79.7, 186.7), Offset(89.5, 217.9), Offset(114.9, 235.3), Offset(146.9, 242.8), Offset(176.0, 231.8), Offset(200.3, 213.6)],
      end: Offset(214, 192),
    ),
    StrokeCheckpoints(
      start: Offset(214, 103),
      inBetween: [Offset(214, 137.8), Offset(214, 173.9), Offset(214, 210.2), Offset(214, 246.7), Offset(209.2, 280.5), Offset(194.7, 307.3), Offset(169.1, 323.9), Offset(133.2, 325.5), Offset(105.0, 312.0)],
      end: Offset(88, 292),
    ),
  ],
  'H': [
    StrokeCheckpoints(
      start: Offset(83, 57),
      inBetween: [Offset(83, 95.0), Offset(83, 131.9), Offset(83, 168.9), Offset(83, 205.8)],
      end: Offset(83, 246),
    ),
    StrokeCheckpoints(
      start: Offset(218, 57),
      inBetween: [Offset(218, 95.6), Offset(218, 131.5), Offset(218, 167.4), Offset(218, 203.3)],
      end: Offset(218, 246),
    ),
    StrokeCheckpoints(
      start: Offset(83, 149),
      inBetween: [Offset(127.6, 149), Offset(170.2, 149)],
      end: Offset(218, 149),
    ),
  ],
  'h': [
    StrokeCheckpoints(
      start: Offset(90, 46),
      inBetween: [Offset(90, 84.8), Offset(90, 124.3), Offset(90, 163.8), Offset(90, 203.3)],
      end: Offset(90, 242),
    ),
    StrokeCheckpoints(
      start: Offset(90, 141),
      inBetween: [Offset(117.0, 113.3), Offset(152.1, 103.9), Offset(187.3, 113.0), Offset(207.2, 136.7), Offset(212, 172.4), Offset(212, 210.1)],
      end: Offset(212, 242),
    ),
  ],
  'I': [
    StrokeCheckpoints(
      start: Offset(150, 60),
      inBetween: [Offset(150, 94.7), Offset(150, 131.4), Offset(150, 168.0), Offset(150, 204.7)],
      end: Offset(150, 240),
    ),
  ],
  'i': [
    StrokeCheckpoints(
      start: Offset(150, 106),
      inBetween: [Offset(150, 137.6), Offset(150, 173.0), Offset(150, 208.4)],
      end: Offset(150, 242),
    ),
    StrokeCheckpoints(
      start: Offset(150, 45),
      inBetween: [],
      end: Offset(150, 45),
    ),
  ],
  'J': [
    StrokeCheckpoints(
      start: Offset(187, 59),
      inBetween: [Offset(187, 94.1), Offset(187, 131.6), Offset(187, 169.0), Offset(185.0, 204.5), Offset(170.6, 236.5), Offset(140.0, 248.6), Offset(112.3, 234.3)],
      end: Offset(98, 210),
    ),
  ],
  'j': [
    StrokeCheckpoints(
      start: Offset(150, 106),
      inBetween: [Offset(150, 138.0), Offset(150, 173.1), Offset(150, 208.7), Offset(150, 243.2), Offset(150, 278.6), Offset(140.8, 309.4)],
      end: Offset(115, 322),
    ),
    StrokeCheckpoints(
      start: Offset(150, 46),
      inBetween: [],
      end: Offset(150, 46),
    ),
  ],
  'K': [
    StrokeCheckpoints(
      start: Offset(98, 59),
      inBetween: [Offset(98, 95.8), Offset(98, 131.9), Offset(98, 168.0), Offset(98, 204.1)],
      end: Offset(98, 242),
    ),
    StrokeCheckpoints(
      start: Offset(205, 59),
      inBetween: [Offset(184.9, 78.9), Offset(163.1, 102.7), Offset(140.9, 125.2), Offset(122.6, 150.2), Offset(140.8, 174.3), Offset(161.7, 195.9), Offset(184.4, 217.8)],
      end: Offset(205, 242),
    ),
  ],
  'k': [
    StrokeCheckpoints(
      start: Offset(108, 46),
      inBetween: [Offset(108, 82.4), Offset(108, 121.3), Offset(108, 160.1), Offset(108, 198.9)],
      end: Offset(108, 242),
    ),
    StrokeCheckpoints(
      start: Offset(194, 102),
      inBetween: [Offset(173.4, 127.0), Offset(149.4, 149.3), Offset(131.1, 174.1), Offset(154.0, 199.4), Offset(175, 221)],
      end: Offset(194, 242),
    ),
  ],
  'L': [
    StrokeCheckpoints(
      start: Offset(124, 61),
      inBetween: [Offset(124, 97.6), Offset(124, 134.6), Offset(124.0, 171.7), Offset(124, 208.8)],
      end: Offset(124, 243),
    ),
    StrokeCheckpoints(
      start: Offset(124, 243),
      inBetween: [Offset(160.5, 243)],
      end: Offset(197, 243),
    ),
  ],
  'l': [
    StrokeCheckpoints(
      start: Offset(150, 45),
      inBetween: [Offset(150, 86.2), Offset(150, 125.2), Offset(150, 164.2), Offset(150, 203.2)],
      end: Offset(150, 240),
    ),
  ],
  'M': [
    StrokeCheckpoints(
      start: Offset(60, 63),
      inBetween: [Offset(60, 111.4), Offset(60, 155.0), Offset(60, 198.6)],
      end: Offset(60, 243),
    ),
    StrokeCheckpoints(
      start: Offset(60, 63),
      inBetween: [Offset(80.2, 98.7), Offset(97.5, 134.1), Offset(114.9, 169.5), Offset(132.3, 204.9)],
      end: Offset(150, 243),
    ),
    StrokeCheckpoints(
      start: Offset(150, 243),
      inBetween: [Offset(169.4, 201.1), Offset(187.2, 166.7), Offset(205.0, 132.2), Offset(222.8, 97.8)],
      end: Offset(243, 63),
    ),
    StrokeCheckpoints(
      start: Offset(243, 63),
      inBetween: [Offset(243, 100.8), Offset(243, 136.3), Offset(243, 171.8), Offset(243, 207.3)],
      end: Offset(243, 243),
    ),
  ],
  'm': [
    StrokeCheckpoints(
      start: Offset(33, 104),
      inBetween: [Offset(33, 137.3), Offset(33, 173.5), Offset(33, 209.6)],
      end: Offset(33, 244),
    ),
    StrokeCheckpoints(
      start: Offset(33, 140),
      inBetween: [Offset(53.4, 118.7), Offset(80.5, 102.4), Offset(111.6, 98.2), Offset(139.6, 110.6), Offset(150, 139.8), Offset(150, 173.9), Offset(150, 208.2)],
      end: Offset(150, 244),
    ),
    StrokeCheckpoints(
      start: Offset(150, 140),
      inBetween: [Offset(169.7, 123.0), Offset(195.8, 104.7), Offset(230.4, 101.1), Offset(256.6, 117.1), Offset(267, 145.3), Offset(267, 179.7), Offset(267, 214.5)],
      end: Offset(267, 244),
    ),
  ],
  'N': [
    StrokeCheckpoints(
      start: Offset(82, 54),
      inBetween: [Offset(82, 97.6), Offset(82, 133.5), Offset(82, 169.5), Offset(82, 205.4)],
      end: Offset(82, 246),
    ),
    StrokeCheckpoints(
      start: Offset(82, 54),
      inBetween: [Offset(109.3, 91.4), Offset(131.8, 123.1), Offset(154.2, 154.8), Offset(176.6, 186.6), Offset(199.0, 218.3)],
      end: Offset(219, 246),
    ),
    StrokeCheckpoints(
      start: Offset(219, 246),
      inBetween: [Offset(219, 205.4), Offset(219, 168.5), Offset(219, 131.7), Offset(219, 94.9)],
      end: Offset(219, 54),
    ),
  ],
  'n': [
    StrokeCheckpoints(
      start: Offset(92, 102),
      inBetween: [Offset(92, 150.3), Offset(92, 195.8)],
      end: Offset(92, 243),
    ),
    StrokeCheckpoints(
      start: Offset(92, 138),
      inBetween: [Offset(111.5, 119.9), Offset(137.6, 104.2), Offset(172.3, 101.1), Offset(195.8, 120.1), Offset(212, 146.9), Offset(212, 180.9), Offset(212, 214.4)],
      end: Offset(212, 243),
    ),
  ],
  'O': [
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(118.8, 61.0), Offset(91.4, 75.2), Offset(71.4, 99.9), Offset(63.3, 132.1), Offset(58.1, 166.3), Offset(70.6, 196.1), Offset(90.0, 221.7), Offset(115.2, 239.2), Offset(148.2, 246.4), Offset(182.2, 241.0), Offset(209.6, 226.1), Offset(230.8, 202.4), Offset(242.0, 171.1), Offset(239.3, 137.2), Offset(233.4, 103.4), Offset(212.6, 79.4), Offset(184.2, 62.9)],
      end: Offset(150, 55),
    ),
  ],
  'o': [
    StrokeCheckpoints(
      start: Offset(150, 101),
      inBetween: [Offset(119.8, 107.8), Offset(95.3, 126.2), Offset(85.0, 155.9), Offset(81.4, 189.7), Offset(95.5, 218.9), Offset(119.2, 237.8), Offset(153.3, 243.9), Offset(185.3, 238.2), Offset(208.0, 215.4), Offset(218.0, 185.3), Offset(218.0, 150.4), Offset(203.0, 123.9), Offset(177.5, 106.2)],
      end: Offset(150, 101),
    ),
  ],
  'P': [
    StrokeCheckpoints(
      start: Offset(100, 58),
      inBetween: [Offset(100, 94.9), Offset(100, 130.6), Offset(100, 166.3), Offset(100, 202.0)],
      end: Offset(100, 241),
    ),
    StrokeCheckpoints(
      start: Offset(100, 58),
      inBetween: [Offset(138.5, 57.0), Offset(173.5, 60.5), Offset(201.8, 75.9), Offset(212.8, 106.2), Offset(202.0, 134.3), Offset(173.7, 152.5), Offset(140.6, 157.8)],
      end: Offset(100, 158),
    ),
  ],
  'p': [
    StrokeCheckpoints(
      start: Offset(85, 105),
      inBetween: [Offset(85, 141.4), Offset(85, 178.1), Offset(85, 214.8), Offset(85, 251.6), Offset(85, 288.3)],
      end: Offset(85, 318),
    ),
    StrokeCheckpoints(
      start: Offset(85, 144),
      inBetween: [Offset(108.7, 119.1), Offset(134.7, 102.4), Offset(171.4, 102.3), Offset(200.7, 116.3), Offset(218.9, 141.9), Offset(223.6, 175.4), Offset(212.7, 207.5), Offset(195.2, 235.3), Offset(164.3, 245.8), Offset(130.5, 241.7), Offset(106.3, 221.7)],
      end: Offset(85, 198),
    ),
  ],
  'Q': [
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(118.8, 61.0), Offset(91.4, 75.2), Offset(71.4, 99.9), Offset(63.3, 132.1), Offset(58.1, 166.3), Offset(70.6, 196.1), Offset(90.0, 221.7), Offset(115.2, 239.2), Offset(148.2, 246.4), Offset(182.2, 241.0), Offset(209.6, 226.1), Offset(230.8, 202.4), Offset(242.0, 171.1), Offset(239.3, 137.2), Offset(233.4, 103.4), Offset(212.6, 79.4), Offset(184.2, 62.9)],
      end: Offset(150, 55),
    ),
    StrokeCheckpoints(
      start: Offset(189, 239),
      inBetween: [Offset(210.4, 262.1)],
      end: Offset(231, 284),
    ),
  ],
  'q': [
    StrokeCheckpoints(
      start: Offset(214, 146),
      inBetween: [Offset(194.6, 126.3), Offset(168.4, 110.0), Offset(135.5, 104.7), Offset(103.5, 111.2), Offset(81.0, 129.8), Offset(70.6, 158.8), Offset(71.6, 193.8), Offset(85.0, 223.0), Offset(109.3, 240.3), Offset(143.5, 245.0), Offset(173.4, 238.2), Offset(199.2, 220.0)],
      end: Offset(214, 197),
    ),
    StrokeCheckpoints(
      start: Offset(215, 105),
      inBetween: [Offset(215, 141.1), Offset(215, 176.5), Offset(215, 211.8), Offset(215, 247.1), Offset(215, 282.4)],
      end: Offset(215, 318),
    ),
  ],
  'R': [
    StrokeCheckpoints(
      start: Offset(97, 60),
      inBetween: [Offset(97, 92.9), Offset(97, 130.2), Offset(97, 167.5), Offset(97, 204.9)],
      end: Offset(97, 245),
    ),
    StrokeCheckpoints(
      start: Offset(97, 60),
      inBetween: [Offset(132.7, 58.9), Offset(168.1, 62.8), Offset(197.6, 77.8), Offset(207.2, 108.8), Offset(200.1, 140.7), Offset(170.7, 156.6), Offset(133.7, 158.6)],
      end: Offset(97, 158),
    ),
    StrokeCheckpoints(
      start: Offset(154, 158),
      inBetween: [Offset(177.6, 200.5)],
      end: Offset(203, 245),
    ),
  ],
  'r': [
    StrokeCheckpoints(
      start: Offset(132, 102),
      inBetween: [Offset(132, 148.6), Offset(132, 195.0)],
      end: Offset(132, 242),
    ),
    StrokeCheckpoints(
      start: Offset(132, 148),
      inBetween: [Offset(157, 118)],
      end: Offset(187, 102),
    ),
  ],
  'S': [
    StrokeCheckpoints(
      start: Offset(198, 85),
      inBetween: [Offset(178.7, 63.0), Offset(146.5, 55.5), Offset(114.1, 63.1), Offset(95.6, 87.3), Offset(97.8, 120.2), Offset(122.8, 138.1), Offset(153.2, 149.4), Offset(182.0, 160.3), Offset(203.1, 183.4), Offset(201.8, 216.3), Offset(179.9, 238.9), Offset(148.0, 246.4), Offset(117.1, 237.8)],
      end: Offset(98, 214),
    ),
  ],
  's': [
    StrokeCheckpoints(
      start: Offset(196, 128),
      inBetween: [Offset(177.8, 107.3), Offset(146.1, 101.1), Offset(114.7, 109.4), Offset(102.8, 136.4), Offset(119.2, 158.8), Offset(145.4, 171.9), Offset(174.4, 183.9), Offset(195.9, 204.6), Offset(186.6, 235), Offset(159.0, 245), Offset(123.8, 242.0)],
      end: Offset(103, 218),
    ),
  ],
  'T': [
    StrokeCheckpoints(
      start: Offset(150, 58),
      inBetween: [Offset(150, 93.4), Offset(150, 130.8), Offset(150, 168.1), Offset(150, 205.4)],
      end: Offset(150, 242),
    ),
    StrokeCheckpoints(
      start: Offset(90, 58),
      inBetween: [Offset(127.7, 58), Offset(168.4, 58)],
      end: Offset(210, 58),
    ),
  ],
  't': [
    StrokeCheckpoints(
      start: Offset(137, 63),
      inBetween: [Offset(137, 99.8), Offset(137, 136.6), Offset(137, 172.0), Offset(138.9, 208.9), Offset(148.4, 240.7)],
      end: Offset(184, 243),
    ),
    StrokeCheckpoints(
      start: Offset(116, 102),
      inBetween: [Offset(148.9, 102)],
      end: Offset(183, 102),
    ),
  ],
  'U': [
    StrokeCheckpoints(
      start: Offset(85, 60),
      inBetween: [Offset(85, 95.3), Offset(85.0, 130.5), Offset(85.0, 167.0), Offset(85, 199.7), Offset(105.1, 226.0), Offset(133.9, 239.1), Offset(169.5, 241.4), Offset(198.6, 224.2), Offset(215, 200.2), Offset(215, 165.0), Offset(215.0, 129.4), Offset(215, 94.5)],
      end: Offset(215, 60),
    ),
  ],
  'u': [
    StrokeCheckpoints(
      start: Offset(89, 103),
      inBetween: [Offset(89, 142.6), Offset(89, 178.0), Offset(91, 212.2), Offset(118.3, 237.8), Offset(155.3, 242.2), Offset(185.5, 231.0)],
      end: Offset(210, 201),
    ),
    StrokeCheckpoints(
      start: Offset(210, 103),
      inBetween: [Offset(210, 139.8), Offset(210, 174.8), Offset(210, 209.9)],
      end: Offset(210, 243),
    ),
  ],
  'V': [
    StrokeCheckpoints(
      start: Offset(74, 58),
      inBetween: [Offset(89.3, 97.9), Offset(104.4, 135.3), Offset(119.5, 172.7), Offset(134.6, 210.1)],
      end: Offset(150, 246),
    ),
    StrokeCheckpoints(
      start: Offset(150, 246),
      inBetween: [Offset(162.6, 217.4), Offset(175.5, 184.8), Offset(188.5, 152.2), Offset(201.4, 119.6), Offset(214.3, 87.0)],
      end: Offset(226, 58),
    ),
  ],
  'v': [
    StrokeCheckpoints(
      start: Offset(90, 104),
      inBetween: [Offset(104.1, 141.9), Offset(119.6, 179.1), Offset(135.1, 216.4)],
      end: Offset(150, 250),
    ),
    StrokeCheckpoints(
      start: Offset(150, 250),
      inBetween: [Offset(166.9, 214.2), Offset(182.2, 176.5), Offset(197.5, 138.8)],
      end: Offset(210, 104),
    ),
  ],
  'W': [
    StrokeCheckpoints(
      start: Offset(27, 58),
      inBetween: [Offset(39.8, 98.5), Offset(51.3, 137.3), Offset(62.8, 176.0), Offset(74.3, 214.8)],
      end: Offset(85, 250),
    ),
    StrokeCheckpoints(
      start: Offset(85, 250),
      inBetween: [Offset(97.1, 220.1), Offset(108.3, 185.5), Offset(119.6, 151.0), Offset(130.8, 116.4), Offset(142.1, 81.8)],
      end: Offset(150, 58),
    ),
    StrokeCheckpoints(
      start: Offset(150, 58),
      inBetween: [Offset(164.4, 94.1), Offset(177.1, 133.9), Offset(189.8, 173.6), Offset(202.5, 213.3)],
      end: Offset(215, 250),
    ),
    StrokeCheckpoints(
      start: Offset(215, 250),
      inBetween: [Offset(226.7, 211.1), Offset(238.9, 172.2), Offset(251.1, 133.3), Offset(263.3, 94.4)],
      end: Offset(275, 58),
    ),
  ],
  'w': [
    StrokeCheckpoints(
      start: Offset(48, 98),
      inBetween: [Offset(58.7, 136.4), Offset(71.0, 175.3), Offset(83.3, 214.1)],
      end: Offset(97, 254),
    ),
    StrokeCheckpoints(
      start: Offset(97, 254),
      inBetween: [Offset(110.7, 212.1), Offset(124.7, 171.2), Offset(138.7, 130.3)],
      end: Offset(150, 98),
    ),
    StrokeCheckpoints(
      start: Offset(150, 98),
      inBetween: [Offset(164.9, 134.3), Offset(178.0, 174.7), Offset(191.2, 215.1)],
      end: Offset(202, 254),
    ),
    StrokeCheckpoints(
      start: Offset(202, 254),
      inBetween: [Offset(219.8, 215.9), Offset(231.5, 174.6), Offset(243.2, 133.2)],
      end: Offset(252, 98),
    ),
  ],
  'X': [
    StrokeCheckpoints(
      start: Offset(94, 58),
      inBetween: [Offset(109.2, 84.6), Offset(129.0, 116.6), Offset(148.7, 148.7), Offset(168.5, 180.8), Offset(188.3, 212.9)],
      end: Offset(209, 246),
    ),
    StrokeCheckpoints(
      start: Offset(209, 58),
      inBetween: [Offset(191.3, 84.8), Offset(170.9, 117.1), Offset(150.5, 149.4), Offset(130.2, 181.7), Offset(109.8, 214.0)],
      end: Offset(94, 246),
    ),
  ],
  'x': [
    StrokeCheckpoints(
      start: Offset(103, 99),
      inBetween: [Offset(127.3, 137.3), Offset(150.7, 173.5), Offset(174.1, 209.6)],
      end: Offset(197, 246),
    ),
    StrokeCheckpoints(
      start: Offset(197, 99),
      inBetween: [Offset(172.8, 139.2), Offset(149.9, 173.7), Offset(126.9, 208.2)],
      end: Offset(103, 246),
    ),
  ],
  'Y': [
    StrokeCheckpoints(
      start: Offset(90, 58),
      inBetween: [Offset(109.8, 95.1), Offset(130.2, 134.6)],
      end: Offset(150, 170),
    ),
    StrokeCheckpoints(
      start: Offset(210, 58),
      inBetween: [Offset(188.4, 99.6), Offset(168.8, 137.6)],
      end: Offset(150, 170),
    ),
    StrokeCheckpoints(
      start: Offset(150, 170),
      inBetween: [Offset(150, 206.1)],
      end: Offset(150, 245),
    ),
  ],
  'y': [
    StrokeCheckpoints(
      start: Offset(88, 101),
      inBetween: [Offset(103.7, 139.5), Offset(118.9, 177.9), Offset(134.0, 216.3)],
      end: Offset(149, 252),
    ),
    StrokeCheckpoints(
      start: Offset(214, 101),
      inBetween: [Offset(198.8, 139.2), Offset(183.2, 175.6), Offset(167.6, 212.1), Offset(152.0, 248.5), Offset(136.4, 284.9)],
      end: Offset(120, 323),
    ),
  ],
  'Z': [
    StrokeCheckpoints(
      start: Offset(93, 57),
      inBetween: [Offset(133.0, 57), Offset(170.5, 57)],
      end: Offset(207, 57),
    ),
    StrokeCheckpoints(
      start: Offset(207, 57),
      inBetween: [Offset(189.6, 87.5), Offset(170.1, 119.5), Offset(150.5, 151.5), Offset(131.0, 183.5), Offset(111.5, 215.5)],
      end: Offset(93, 243),
    ),
    StrokeCheckpoints(
      start: Offset(93, 243),
      inBetween: [Offset(132.6, 243), Offset(172.1, 243)],
      end: Offset(207, 243),
    ),
  ],
  'z': [
    StrokeCheckpoints(
      start: Offset(100, 102),
      inBetween: [Offset(148.0, 102)],
      end: Offset(197, 102),
    ),
    StrokeCheckpoints(
      start: Offset(197, 102),
      inBetween: [Offset(171.1, 139.8), Offset(148.3, 174.8), Offset(125.5, 209.9)],
      end: Offset(100, 245),
    ),
    StrokeCheckpoints(
      start: Offset(100, 245),
      inBetween: [Offset(150.4, 245)],
      end: Offset(197, 245),
    ),
  ],
  'Å': [
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(136.0, 92.5), Offset(121.2, 130.9), Offset(106.3, 169.3), Offset(91.5, 207.7)],
      end: Offset(77, 243),
    ),
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(165.8, 92.5), Offset(180.7, 130.9), Offset(195.7, 169.3), Offset(210.6, 207.7)],
      end: Offset(222, 243),
    ),
    StrokeCheckpoints(
      start: Offset(97, 196),
      inBetween: [Offset(131.4, 196.6), Offset(167.8, 196.4)],
      end: Offset(207, 196),
    ),
    StrokeCheckpoints(
      start: Offset(150, -25),
      inBetween: [Offset(131.1, -19.5), Offset(126.1, -2.0), Offset(132.2, 15.0), Offset(150.0, 21.1), Offset(169.2, 15.0), Offset(174.2, -1.4), Offset(166.9, -20.0)],
      end: Offset(150, -25),
    ),
  ],
  'å': [
    StrokeCheckpoints(
      start: Offset(213, 143),
      inBetween: [Offset(192.3, 123.1), Offset(167.5, 107.5), Offset(135.6, 101.4), Offset(105.9, 112.1), Offset(85.6, 131.9), Offset(76.7, 161.5), Offset(76.7, 196.7), Offset(94.0, 221.4), Offset(114.8, 241.7), Offset(146.2, 246.6), Offset(174.7, 238.1), Offset(198.0, 219.8)],
      end: Offset(213, 200),
    ),
    StrokeCheckpoints(
      start: Offset(213, 100),
      inBetween: [Offset(213, 137.0), Offset(213, 172.3), Offset(213, 207.7)],
      end: Offset(213, 246),
    ),
    StrokeCheckpoints(
      start: Offset(150, 18),
      inBetween: [Offset(133.0, 23.6), Offset(126.9, 41.7), Offset(132.2, 58.0), Offset(149, 65), Offset(166.7, 59.7), Offset(173.6, 43), Offset(170.3, 25.8)],
      end: Offset(150, 18),
    ),
  ],
  'Ä': [
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(136.0, 92.5), Offset(121.2, 130.9), Offset(106.3, 169.3), Offset(91.5, 207.7)],
      end: Offset(77, 243),
    ),
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(165.8, 92.5), Offset(180.7, 130.9), Offset(195.7, 169.3), Offset(210.6, 207.7)],
      end: Offset(222, 243),
    ),
    StrokeCheckpoints(
      start: Offset(97, 196),
      inBetween: [Offset(131.4, 196.6), Offset(167.8, 196.4)],
      end: Offset(207, 196),
    ),
    StrokeCheckpoints(
      start: Offset(126, 10),
      inBetween: [],
      end: Offset(126, 10),
    ),
    StrokeCheckpoints(
      start: Offset(174, 10),
      inBetween: [],
      end: Offset(174, 10),
    ),
  ],
  'ä': [
    StrokeCheckpoints(
      start: Offset(213, 143),
      inBetween: [Offset(192.3, 123.1), Offset(167.5, 107.5), Offset(135.6, 101.4), Offset(105.9, 112.1), Offset(85.6, 131.9), Offset(76.7, 161.5), Offset(76.7, 196.7), Offset(94.0, 221.4), Offset(114.8, 241.7), Offset(146.2, 246.6), Offset(174.7, 238.1), Offset(198.0, 219.8)],
      end: Offset(213, 200),
    ),
    StrokeCheckpoints(
      start: Offset(213, 100),
      inBetween: [Offset(213, 137.0), Offset(213, 172.3), Offset(213, 207.7)],
      end: Offset(213, 246),
    ),
    StrokeCheckpoints(
      start: Offset(126, 53),
      inBetween: [],
      end: Offset(126, 53),
    ),
    StrokeCheckpoints(
      start: Offset(174, 53),
      inBetween: [],
      end: Offset(174, 53),
    ),
  ],
  'Ö': [
    StrokeCheckpoints(
      start: Offset(150, 55),
      inBetween: [Offset(118.8, 61.0), Offset(91.4, 75.2), Offset(71.4, 99.9), Offset(63.3, 132.1), Offset(58.1, 166.3), Offset(70.6, 196.1), Offset(90.0, 221.7), Offset(115.2, 239.2), Offset(148.2, 246.4), Offset(182.2, 241.0), Offset(209.6, 226.1), Offset(230.8, 202.4), Offset(242.0, 171.1), Offset(239.3, 137.2), Offset(233.4, 103.4), Offset(212.6, 79.4), Offset(184.2, 62.9)],
      end: Offset(150, 55),
    ),
    StrokeCheckpoints(
      start: Offset(127, 10),
      inBetween: [],
      end: Offset(127, 10),
    ),
    StrokeCheckpoints(
      start: Offset(176, 10),
      inBetween: [],
      end: Offset(176, 10),
    ),
  ],
  'ö': [
    StrokeCheckpoints(
      start: Offset(150, 101),
      inBetween: [Offset(119.8, 107.8), Offset(95.3, 126.2), Offset(85.0, 155.9), Offset(81.4, 189.7), Offset(95.5, 218.9), Offset(119.2, 237.8), Offset(153.3, 243.9), Offset(185.3, 238.2), Offset(208.0, 215.4), Offset(218.0, 185.3), Offset(218.0, 150.4), Offset(203.0, 123.9), Offset(177.5, 106.2)],
      end: Offset(150, 101),
    ),
    StrokeCheckpoints(
      start: Offset(126, 51),
      inBetween: [],
      end: Offset(126, 51),
    ),
    StrokeCheckpoints(
      start: Offset(174, 51),
      inBetween: [],
      end: Offset(174, 51),
    ),
  ],
  '#': [ // Letter template
    StrokeCheckpoints(
      start: Offset(0, 0),
      inBetween: [],
      end: Offset(0, 0),
    ),
  ],
  // Add additional letters here...
};

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({Key? key}) : super(key: key);

  @override
  _GameplayScreenState createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  // Settings service.
  final SettingsService _settingsService = SettingsService();
  List<String> _letters = [];
  bool _isLoading = true;
  int _currentLetterIndex = 0;
  String? letter; // Current letter to trace.
  String _language = "en"; // default language
  bool _highscoreTriggered = false;

  // Tracing variables.
  List<Offset> _userStroke = [];
  List<List<Offset>> _completedStrokes = [];
  int currentStrokeIndex = 0;
  late List<StrokeCheckpoints> strokeCheckpointsList;

  // Scoring.
  int _score = 100;
  final int _letterBonus = 10; // Points awarded per correctly drawn letter.
  final int _letterPenalty = 2; // Points deducted for incorrect stroke.

  // Help state.
  bool _showHelp = false;
  final int _helpCost = 5; // Points deducted per help press.
  late AnimationController _helpAnimationController;
  final Duration _helpDuration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _loadSettingsAndGenerateDictionary();
    _helpAnimationController = AnimationController(
      vsync: this,
      duration: _helpDuration,
    );
  }

  @override
  void dispose() {
    _helpAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettingsAndGenerateDictionary() async {
    final language = await _settingsService.getLanguage();
    final gameMode = await _settingsService.getGameMode();
    final letterOrder = await _settingsService.getLetterOrder();

    // Generate the basic English alphabet.
    List<String> letters = 'abcdefghijklmnopqrstuvwxyz'.split('');

    // If language is Swedish, add å, ä, ö.
    if (language == 'sv') {
      letters.addAll(['å', 'ä', 'ö']);
    }

    // Determine letter order.
    if (letterOrder == 'random') {
      letters.shuffle();
    }
    // If letterOrder is 'alphabetic', we leave the list as is.

    // Adjust capitalization based on game mode.
    Random random = Random();
    List<String> formattedLetters = letters.map((letter) {
      if (gameMode == 'random') {
        return random.nextBool() ? letter.toUpperCase() : letter.toLowerCase();
      } else if (gameMode == 'uppercase') {
        return letter.toUpperCase();
      } else if (gameMode == 'lowercase') {
        return letter.toLowerCase();
      }
      return letter; // fallback
    }).toList();

    setState(() {
      _letters = formattedLetters;
      _isLoading = false;
      _currentLetterIndex = 0;
      letter = _letters[_currentLetterIndex];
      // For testing only, override letter:
      letter = "ä";
      strokeCheckpointsList = letterStrokePaths[letter!] ?? [];
      _language = language; // Store language for later use.
    });
  }

  /// Advances the game to the next letter.
  void _nextLetter() {
    if (_currentLetterIndex < _letters.length - 1) {
      _currentLetterIndex++;
    } else {
      // Restart from beginning if reached the end.
      _currentLetterIndex = 0;
    }
    letter = _letters[_currentLetterIndex];
    strokeCheckpointsList = letterStrokePaths[letter!] ?? [];
    currentStrokeIndex = 0;
    _completedStrokes.clear();
    _userStroke.clear();
  }

  /// Called when help is requested.
  void _requestHelp() {
    // Translate the "not enough points" message.
    final notEnoughPointsMessage = _language == "sv"
        ? "Inte tillräckligt med poäng för hjälp!"
        : "Not enough points for help!";
    if (_score >= _helpCost) {
      setState(() {
        _score -= _helpCost;
        _showHelp = true;
      });
      _helpAnimationController.forward(from: 0.0);
      _helpAnimationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Wait 1 second after the animation finishes, then remove help.
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _showHelp = false;
            });
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(notEnoughPointsMessage)),
      );
    }
  }

  /// Checks and updates the high score if the current score is greater.
  Future<void> _updateHighScore() async {
    int currentHighScore = await _settingsService.getHighScore();
    if (_score > currentHighScore) {
      await _settingsService.setHighScore(_score);
      // Trigger the event only once per session.
      if (!_highscoreTriggered) {
        _highscoreTriggered = true;
        _triggerHighScoreEvent();
      }
    }
  }

  void _triggerHighScoreEvent() {
    // For example, show a dialog or play a sound.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_language == "sv" ? "Nytt rekord!" : "New High Score!"),
        content: Text(_language == "sv"
            ? "Grattis! Du har satt ett nytt rekord."
            : "Congratulations! You've set a new high score."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_language == "sv" ? "OK" : "OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || letter == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Loading"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Update the stroke checkpoints for the current letter.
    strokeCheckpointsList = letterStrokePaths[letter!] ?? [];

    // Translate AppBar title text.
    final String appBarTitle = _language == "sv"
        ? "Bokstav: $letter  |  Poäng: $_score"
        : "Letter: $letter  |  Score: $_score";

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _requestHelp,
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        double designWidth = 300;
        double designHeight = 300;
        double scale = min(constraints.maxWidth / designWidth, constraints.maxHeight / designHeight);
        double dx = (constraints.maxWidth - designWidth * scale) / 2;
        double dy = (constraints.maxHeight - designHeight * scale) / 2;

        // Helper to calculate the cumulative distance of a stroke.
        double calculateStrokeDistance(List<Offset> points) {
          double total = 0;
          for (int i = 1; i < points.length; i++) {
            total += (points[i] - points[i - 1]).distance;
          }
          return total;
        }

        // Helper to determine if the expected stroke is a dot stroke.
        bool isDotStroke(StrokeCheckpoints cp) {
          return cp.inBetween.isEmpty && cp.start == cp.end;
        }

        const double minStrokeDistance = 20.0; // For regular strokes.
        const double dotTolerance = 20.0;      // Allowed tolerance for dot taps.

        return GestureDetector(
          onPanStart: (details) {
            Offset designPos = (details.localPosition - Offset(dx, dy)) / scale;
            print("Offset: $designPos");
            setState(() {
              _userStroke = [designPos];
              _showHelp = false;
            });
          },
          onPanUpdate: (details) {
            Offset designPos = (details.localPosition - Offset(dx, dy)) / scale;
            setState(() {
              _userStroke.add(designPos);
            });
          },
          onPanEnd: (details) {
            List<Offset> inBetween = getEvenlyDistributedPointsDynamic(_userStroke, 35.0);
            print("inBetween: $inBetween");

            final expectedStroke = strokeCheckpointsList[currentStrokeIndex];
            bool valid;

            // If this is a dot stroke, validate based on proximity.
            if (isDotStroke(expectedStroke)) {
              if (_userStroke.isEmpty ||
                  (_userStroke.first - expectedStroke.start).distance > dotTolerance) {
                print("Dot stroke invalid: tap not near dot.");
                setState(() {
                  _userStroke = [];
                });
                return;
              } else {
                print("Dot stroke valid.");
                valid = true;
              }
            } else {
              // For regular strokes, use cumulative distance.
              double totalDistance = calculateStrokeDistance(_userStroke);
              if (_userStroke.isEmpty || totalDistance < minStrokeDistance) {
                print("Stroke too short, ignoring. Total distance: $totalDistance");
                setState(() {
                  _userStroke = [];
                });
                return;
              }
              // First, try validating against the current expected stroke.
              valid = isStrokeValid(
                _userStroke,
                expectedStroke,
                20.0, // checkpointTolerance
                20.0, // maxDeviationTolerance
              );
              if (valid) {
                print("Single stroke valid");
              } else if ((currentStrokeIndex + 1) < strokeCheckpointsList.length) {
                // Try combining the current expected stroke with the next.
                final nextExpected = strokeCheckpointsList[currentStrokeIndex + 1];
                List<Offset> combinedPoints = [];
                combinedPoints.addAll(expectedStroke.points);
                combinedPoints.addAll(nextExpected.points);
                valid = isStrokeValid(
                  _userStroke,
                  StrokeCheckpoints(
                    start: combinedPoints.first,
                    inBetween: combinedPoints.sublist(1, combinedPoints.length - 1),
                    end: combinedPoints.last,
                  ),
                  20.0, // checkpointTolerance
                  20.0, // maxDeviationTolerance
                );
                if (valid) {
                  print("Combined stroke (2 segments) is valid");
                  currentStrokeIndex += 1;
                } else if ((currentStrokeIndex + 2) < strokeCheckpointsList.length) {
                  // Try combining three segments.
                  final nextNextExpected = strokeCheckpointsList[currentStrokeIndex + 2];
                  List<Offset> tripleCombinedPoints = [];
                  tripleCombinedPoints.addAll(expectedStroke.points);
                  tripleCombinedPoints.addAll(nextExpected.points);
                  tripleCombinedPoints.addAll(nextNextExpected.points);
                  valid = isStrokeValid(
                    _userStroke,
                    StrokeCheckpoints(
                      start: tripleCombinedPoints.first,
                      inBetween: tripleCombinedPoints.sublist(1, tripleCombinedPoints.length - 1),
                      end: tripleCombinedPoints.last,
                    ),
                    20.0,
                    20.0,
                  );
                  if (valid) {
                    print("Combined stroke (3 segments) is valid");
                    currentStrokeIndex += 2;
                  } else if ((currentStrokeIndex + 3) < strokeCheckpointsList.length) {
                    // Try combining four segments (for letters like W).
                    final nextNextNextExpected = strokeCheckpointsList[currentStrokeIndex + 3];
                    List<Offset> quadrupleCombinedPoints = [];
                    quadrupleCombinedPoints.addAll(expectedStroke.points);
                    quadrupleCombinedPoints.addAll(nextExpected.points);
                    quadrupleCombinedPoints.addAll(nextNextExpected.points);
                    quadrupleCombinedPoints.addAll(nextNextNextExpected.points);
                    valid = isStrokeValid(
                      _userStroke,
                      StrokeCheckpoints(
                        start: quadrupleCombinedPoints.first,
                        inBetween: quadrupleCombinedPoints.sublist(1, quadrupleCombinedPoints.length - 1),
                        end: quadrupleCombinedPoints.last,
                      ),
                      20.0,
                      20.0,
                    );
                    if (valid) {
                      print("Combined stroke (4 segments) is valid");
                      currentStrokeIndex += 3;
                    } else {
                      print("Stroke is invalid");
                    }
                  } else {
                    print("Stroke is invalid");
                  }
                } else {
                  print("Stroke is invalid");
                }
              } else {
                print("Stroke is invalid");
              }
            }

            if (currentStrokeIndex < strokeCheckpointsList.length) {
              if (valid) {
                _completedStrokes.add(List.from(_userStroke));
                currentStrokeIndex++;
                // If all strokes for this letter are completed, award bonus points,
                // update high score if necessary, and move to next letter.
                if (currentStrokeIndex == strokeCheckpointsList.length) {
                  setState(() {
                    _score += _letterBonus;
                    // TODO: Animation, fireworks, sound and +10
                  });
                  _updateHighScore(); // Update the high score.
                  _nextLetter();
                }
              } else {
                _score -= _letterPenalty;
                // TODO: Animation, -2 on screen, red and negative sound
              }
            }
            setState(() {
              _userStroke = [];
            });
          },
          child: AnimatedBuilder(
            animation: _helpAnimationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: CheckpointPainter(
                  letter: letter!,
                  strokeCheckpoints: currentStrokeIndex < strokeCheckpointsList.length
                      ? strokeCheckpointsList[currentStrokeIndex]
                      : null,
                  userStroke: _userStroke,
                  completedStrokes: _completedStrokes,
                  scale: scale,
                  dx: dx,
                  dy: dy,
                  showHelp: _showHelp,
                  helpProgress: _helpAnimationController.value,
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// Validates the stroke by ensuring:
  /// 1. The first stroke point is within [tolerance] of the expected start.
  /// 2. The last stroke point is within [tolerance] of the expected end.
  /// 3. Each intermediate checkpoint is hit in order (within [tolerance]).
  /// 4. Between each consecutive checkpoint pair, the stroke does not deviate more than [maxDevTol]
  ///    from the straight line connecting them.
  bool isStrokeValid(
      List<Offset> stroke,
      StrokeCheckpoints checkpoints,
      double tolerance,
      double maxDevTol,
      ) {
    List<Offset> expectedPoints = checkpoints.points;
    if (stroke.isEmpty) return false;
    if ((stroke.first - expectedPoints.first).distance > tolerance) return false;
    if ((stroke.last - expectedPoints.last).distance > tolerance) return false;

    List<int> hitIndices = [];
    int cpIndex = 0;
    for (int i = 0; i < stroke.length; i++) {
      if (cpIndex >= expectedPoints.length) break;
      if ((stroke[i] - expectedPoints[cpIndex]).distance <= tolerance) {
        hitIndices.add(i);
        cpIndex++;
      }
    }
    if (hitIndices.length != expectedPoints.length) return false;

    for (int j = 0; j < hitIndices.length - 1; j++) {
      int startIndex = hitIndices[j];
      int endIndex = hitIndices[j + 1];
      Offset p1 = expectedPoints[j];
      Offset p2 = expectedPoints[j + 1];
      for (int k = startIndex; k <= endIndex; k++) {
        double d = distanceToSegment(stroke[k], p1, p2);
        if (d > maxDevTol) return false;
      }
    }
    return true;
  }
}

/// Computes the shortest distance from point [p] to the line segment from [a] to [b].
double distanceToSegment(Offset p, Offset a, Offset b) {
  final ap = p - a;
  final ab = b - a;
  double ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (ab2 == 0) return (p - a).distance;
  double t = (ap.dx * ab.dx + ap.dy * ab.dy) / ab2;
  t = t.clamp(0, 1);
  Offset closest = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
  return (p - closest).distance;
}

/// Returns a list of evenly distributed in-between points along [points]
/// based on a desired spacing. If the intermediate points are nearly collinear
/// with the straight line from the first to the last point (i.e. the maximum
/// deviation is less than [snapThreshold]), the function snaps the stroke to
/// that line and computes evenly distributed points along it. Otherwise, it
/// fits a smooth Catmull–Rom spline to the points and resamples it.
List<Offset> getEvenlyDistributedPointsDynamic(List<Offset> points, double desiredSpacing, {double snapThreshold = 10.0}) {
  if (points.length < 2) return [];
  Offset start = points.first;
  Offset end = points.last;
  double maxDeviation = 0.0;
  for (int i = 1; i < points.length - 1; i++) {
    double d = distanceToSegment(points[i], start, end);
    if (d > maxDeviation) maxDeviation = d;
  }
  if (maxDeviation < snapThreshold) {
    double lineLength = (end - start).distance;
    int count = (lineLength / desiredSpacing).floor() - 1;
    if (count < 1) count = 1;
    double spacing = lineLength / (count + 1);
    List<Offset> result = [];
    for (int i = 1; i <= count; i++) {
      double fraction = i / (count + 1);
      Offset interpolated = Offset.lerp(start, end, fraction)!;
      result.add(interpolated);
    }
    return result;
  }
  const int resolution = 1000;
  List<Offset> sampledPoints = List.generate(
    resolution + 1,
        (i) => _catmullRom(points, i / resolution),
  );
  List<double> cumulative = [0.0];
  for (int i = 1; i < sampledPoints.length; i++) {
    double dist = (sampledPoints[i] - sampledPoints[i - 1]).distance;
    cumulative.add(cumulative.last + dist);
  }
  double totalLength = cumulative.last;
  int count = (totalLength / desiredSpacing).floor() - 1;
  if (count < 1) count = 1;
  double spacing = totalLength / (count + 1);
  List<Offset> result = [];
  for (int i = 1; i <= count; i++) {
    double target = spacing * i;
    int segmentIndex = 0;
    while (segmentIndex < cumulative.length - 1 && cumulative[segmentIndex + 1] < target) {
      segmentIndex++;
    }
    double segmentStart = cumulative[segmentIndex];
    double segmentEnd = cumulative[segmentIndex + 1];
    double tLocal = (target - segmentStart) / (segmentEnd - segmentStart);
    Offset p0 = sampledPoints[segmentIndex];
    Offset p1 = sampledPoints[segmentIndex + 1];
    Offset interpolated = Offset(
      p0.dx + tLocal * (p1.dx - p0.dx),
      p0.dy + tLocal * (p1.dy - p0.dy),
    );
    result.add(interpolated);
  }
  return result;
}

/// Evaluates a Catmull–Rom spline for the given [points] at a global parameter [t] in [0, 1].
Offset _catmullRom(List<Offset> points, double t) {
  int n = points.length;
  int segments = n - 1;
  double segmentT = t * segments;
  int i = segmentT.floor();
  if (i >= segments) {
    i = segments - 1;
    segmentT = 1.0;
  } else {
    segmentT = segmentT - i;
  }
  Offset p0 = i == 0 ? points[i] : points[i - 1];
  Offset p1 = points[i];
  Offset p2 = points[i + 1];
  Offset p3 = (i + 2 < n) ? points[i + 2] : points[i + 1];
  double u = segmentT;
  double u2 = u * u;
  double u3 = u2 * u;
  double x = 0.5 * ((2 * p1.dx) +
      (-p0.dx + p2.dx) * u +
      (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * u2 +
      (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * u3);
  double y = 0.5 * ((2 * p1.dy) +
      (-p0.dy + p2.dy) * u +
      (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * u2 +
      (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * u3);
  return Offset(x, y);
}

/// Defines the expected checkpoints for a single stroke.
class StrokeCheckpoints {
  final Offset start;
  final List<Offset> inBetween;
  final Offset end;

  const StrokeCheckpoints({
    required this.start,
    required this.inBetween,
    required this.end,
  });

  /// Returns the full list of checkpoints in order.
  List<Offset> get points => [start, ...inBetween, end];
}

/// Custom painter that draws the letter, checkpoint markers, completed strokes, the current stroke,
/// and—if help is requested—the animated expected stroke guidance.
class CheckpointPainter extends CustomPainter {
  final String letter;
  final StrokeCheckpoints? strokeCheckpoints;
  final List<Offset> userStroke;
  final List<List<Offset>> completedStrokes;
  final double scale;
  final double dx;
  final double dy;
  final bool showHelp;
  final double helpProgress; // Value from 0.0 to 1.0

  CheckpointPainter({
    required this.letter,
    required this.strokeCheckpoints,
    required this.userStroke,
    required this.completedStrokes,
    required this.scale,
    required this.dx,
    required this.dy,
    required this.showHelp,
    required this.helpProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    // Draw the letter.
    TextSpan span = TextSpan(
      text: letter,
      style: GoogleFonts.poppins(
        fontSize: 300,
        color: Colors.grey.shade300,
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    Offset textPos = Offset((300 - tp.width) / 2, (300 - tp.height) / 2);
    tp.paint(canvas, textPos);

    // Draw completed strokes.
    if (completedStrokes.isNotEmpty) {
      Paint completedPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (var stroke in completedStrokes) {
        if (stroke.isNotEmpty) {
          if (stroke.length == 1) {
            // Draw a dot if the stroke is just a single point.
            Paint fillPaint = Paint()
              ..color = Colors.blue
              ..style = PaintingStyle.fill;
            canvas.drawCircle(stroke.first, 8.0, fillPaint);
          } else {
            Path path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
            for (Offset p in stroke.skip(1)) {
              path.lineTo(p.dx, p.dy);
            }
            canvas.drawPath(path, completedPaint);
          }
        }
      }
    }

    // Draw the current stroke.
    if (userStroke.isNotEmpty) {
      Paint strokePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      Path path = Path()..moveTo(userStroke.first.dx, userStroke.first.dy);
      for (Offset p in userStroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, strokePaint);
    }

    // Draw expected stroke guidance.
    if (strokeCheckpoints != null) {
      List<Offset> points = strokeCheckpoints!.points;

      // If help is active, draw the animated guidance line.
      if (showHelp) {
        for (int i = 0; i < points.length; i++) {
          Color color;
          double radius;
          if (i == 0) {
            color = Colors.green;
            radius = 8.0;
          } else if (i == points.length - 1) {
            color = Colors.red;
            radius = 8.0;
          } else {
            color = Colors.grey;
            radius = 4.0;
          }
          Paint checkpointPaint = Paint()..color = color;
          canvas.drawCircle(points[i], radius, checkpointPaint);
        }

        Paint helpPaint = Paint()
          ..color = Colors.orange
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

        Path fullPath = Path()..moveTo(points.first.dx, points.first.dy);
        for (Offset p in points.skip(1)) {
          fullPath.lineTo(p.dx, p.dy);
        }

        // Use PathMetrics to extract a subpath based on helpProgress.
        Path animatedPath = Path();
        for (final metric in fullPath.computeMetrics()) {
          final length = metric.length * helpProgress;
          animatedPath.addPath(metric.extractPath(0, length), Offset.zero);
        }

        canvas.drawPath(animatedPath, helpPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

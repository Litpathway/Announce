import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

TextStyle syne800(double size, {Color? color}) => GoogleFonts.syne(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color ?? textPrimary,
    );

TextStyle syne700(double size, {Color? color}) => GoogleFonts.syne(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color ?? textPrimary,
    );

TextStyle syne600(double size, {Color? color}) => GoogleFonts.syne(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? textPrimary,
    );

TextStyle dmSans400(double size, {Color? color}) => GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color ?? textPrimary,
    );

TextStyle dmSans300(double size, {Color? color}) => GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.w300,
      color: color ?? textSecondary,
    );

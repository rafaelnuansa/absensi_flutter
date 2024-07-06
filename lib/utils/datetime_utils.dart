import 'package:intl/intl.dart';

class DateTimeUtils {
  static String getFormattedDateTime() {
    DateTime now = DateTime.now();
    String day = _getDay(now.weekday);
    String date = now.day.toString();
    String month = _getMonth(now.month);
    String year = now.year.toString();
    String hour = _addZeroIfNeeded(now.hour);
    String minute = _addZeroIfNeeded(now.minute);
    String second = _addZeroIfNeeded(now.second);
    return '$day, $date $month $year $hour:$minute:$second';
  }

  static String _getDay(int day) {
    switch (day) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  static String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  static String _addZeroIfNeeded(int number) {
    return number < 10 ? '0$number' : '$number';
  }

  static String formatDateWithoutTime(DateTime? date) {
    // Ubah tipe parameter menjadi nullable
    return date != null
        ? DateFormat('dd MMMM yyyy').format(date) // Format tanggal
        : ''; // Atur pesan default jika tanggal null
  }

  static String formatDate(String dateString) {
    try {
      String inputFormat = 'yyyy-MM-dd'; // Format masukan
      String outputFormat = 'dd MMMM yyyy'; // Format keluaran

      // Parse string ke dalam objek DateTime sesuai dengan format input
      DateTime date = DateFormat(inputFormat).parse(dateString);
      // Format objek DateTime ke format yang diinginkan
      return DateFormat(outputFormat).format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return ''; // Jika terjadi kesalahan, kembalikan string kosong
    }
  }
}

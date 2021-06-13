import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/index.dart';
import 'package:uuid/uuid.dart';

class ConsultHelper {
  static Future<List<Doctor>> getHeroDoctors() async {
    return  FirebaseFirestore.instance
        .collection('doctors')
        .where('hero', isEqualTo: true)
        .get()
        .then((e) {
      final _docs = e.docs;
      final _doctors = <Doctor>[];

      _docs.forEach((e) {
        final _ = Doctor.getModel(e.data(), e.id);
        _doctors.add(_);
      });

      return _doctors;
    });
  }

  static Future<List<Doctor>> getTopRatedDoctors() async {
    return  FirebaseFirestore.instance
        .collection('doctors')
        .where('hero', isEqualTo: false)
        .get()
        .then((e) {
      final _docs = e.docs;
      final _doctors = <Doctor>[];

      _docs.forEach((e) {
        final _ = Doctor.getModel(e.data(), e.id);
        _doctors.add(_);
      });

      return _doctors;
    });
  }

  static Future<bool> createAppointment({
    String userID,
    String username,
    String userImage,
    String doctorID,
    String doctorName,
    String doctorImage,
    Timestamp timestamp,
    DateTime date,
  }) async {
    const uuid = Uuid();
    final _appointmentID = uuid.v4();
    // Calculate Final Timestamp
    final _timestamp = Timestamp.fromDate(DateTime(date.year, date.month,
        date.day, timestamp.toDate().hour, timestamp.toDate().minute, 0));

    final _appointmentList = [
      {
        'timestamp': _timestamp,
        'doctorID': doctorID,
        'doctor_name': doctorName,
        'doctor_image': doctorImage,
        'prescription': [],
        'id': _appointmentID
      }
    ];

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(userID)
        .get()
        .then((_) {
      // IF EXISTS THEN UPDATE DOCUMENT
      if (_.exists)
        _.reference
            .update({'appointments': FieldValue.arrayUnion(_appointmentList)});

      // ELSE SET THE DOCUMENT VALUE
      else
        _.reference.set({'appointments': _appointmentList});
    });

    final _appointmentDoctor = {
      'timestamp': _timestamp,
      'doctorID': userID,
      'doctor_name': username,
      'doctor_image': userImage,
      'prescription': [],
      'id': _appointmentID
    };

    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorID)
        .update({
      'appointments': FieldValue.arrayUnion([_appointmentDoctor])
    });

    return true;
  }

  static Stream getAppointmentsSnapshot({String userID, int userType = 0}) {
    // If user is doctor
    if (userType == 2)
      return FirebaseFirestore.instance
          .collection('doctors')
          .doc(userID)
          .get()
          .asStream();

    return FirebaseFirestore.instance
        .collection('appointments')
        .doc(userID)
        .get()
        .asStream();
  }

  static Future<void> addMedicineToAppointment({
    String medicine,
    int course,
    int dosage,
    String userID,
    String appointmentID,
  }) async {
    final _appointments = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(userID)
        .get()
        .then((data) => data.data()['appointments']);

    final _ = <Map<String, dynamic>>[];

    // Get the object
    final _appointmentToBeUpdated = _appointments[
        _appointments.indexWhere((e) => e['id'] == appointmentID)];

    // Remove orignal instance of object from the array
    _appointments
        .removeAt(_appointments.indexWhere((e) => e['id'] == appointmentID));

    // Get the current prescription list
    final _newPrescriptionList = _appointmentToBeUpdated['prescription'];

    // Modify/Update the current prescription list
    _newPrescriptionList
        .add({'name': medicine, 'daily': dosage, 'period': course});

    // Update the object
    final _updatedAppointment = {
      'timestamp': _appointmentToBeUpdated['timestamp'],
      'doctorID': _appointmentToBeUpdated['doctorID'],
      'doctor_name': _appointmentToBeUpdated['doctor_name'],
      'doctor_image': _appointmentToBeUpdated['doctor_image'],
      'prescription': _newPrescriptionList,
      'id': _appointmentToBeUpdated['timestamp']
    };

    // Add the updated object to modified list instance
    _appointments.add(_updatedAppointment);

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(userID)
        .update({'appointments': _appointments});

    final String _doctorID = _updatedAppointment['doctorID'];

    final _docAppointments = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(_doctorID)
        .get()
        .then((data) => data.data()['appointments']);

    // Remove orignal instance of object from the array
    // Get the object
    final _docAppointmentToBeUpdated = _docAppointments
        .removeAt(_docAppointments.indexWhere((e) => e['id'] == appointmentID));

    // Get the current prescription list
    final _newDocPrescriptionList = _docAppointmentToBeUpdated['prescription'];

    // Modify/Update the current prescription list
    _newPrescriptionList
        .add({'name': medicine, 'daily': dosage, 'period': course});

    // Update the object
    final _docUpdatedAppointment = {
      'timestamp': _docAppointmentToBeUpdated['timestamp'],
      'doctorID': _docAppointmentToBeUpdated['doctorID'],
      'doctor_name': _docAppointmentToBeUpdated['doctor_name'],
      'doctor_image': _docAppointmentToBeUpdated['doctor_image'],
      'prescription': _newPrescriptionList,
      'id': _docAppointmentToBeUpdated['timestamp']
    };

    // Add the updated object to modified list instance
    _docAppointments.add(_docUpdatedAppointment);

    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(_doctorID)
        .update({'appointments': _appointments});
  }
}

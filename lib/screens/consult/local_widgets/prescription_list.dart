import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/consult/appointment.dart';
import '../../../services/index.dart';
import '../../../utils/index.dart';
import 'package:flutter/material.dart';

class AppointmentPrescription extends StatefulWidget {
  final AppointmentItem data;
  final int userType;

  const AppointmentPrescription(
      {@required this.data, @required this.userType, Key key})
      : super(key: key);

  @override
  _AppointmentPrescriptionState createState() =>
      _AppointmentPrescriptionState();
}

class _AppointmentPrescriptionState extends State<AppointmentPrescription> {
  final _courseDaysList = List.generate(14, (index) => index);

  final _dosagePerDayList = List.generate(6, (index) => index);

  int _courseDuration;

  int _dosagePerDay;

  AppointmentItem _appointmentdata;

  TextEditingController _medicineController;
  @override
  void initState() {
    super.initState();
    _appointmentdata = widget.data;

    _medicineController = TextEditingController();
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  void _addToAppointment(
      {int dosage, int course, String medicine, BuildContext context}) async {
    Navigator.pop(context);

    print('$dosage $course $medicine');

    if (dosage == null || course == null || medicine?.length == 0) {
      displaySnackbar(context, 'All fields are required');
    } else {
      await ConsultHelper.addMedicineToAppointment(
        medicine: medicine,
        dosage: dosage,
        course: course,
        userID: _appointmentdata.doctorID,
        appointmentID: _appointmentdata.id,
      );

      // Prescription _newPrescription = Prescription(
      //     medicine: medicine, dailyDosage: dosage, courseDays: course);

      final _newPrescriptionList = _appointmentdata.prescription;

      _newPrescriptionList.add(Prescription(
        medicine: medicine,
        dailyDosage: dosage,
        courseDays: course,
      ));

      final _updatedData = AppointmentItem(
          doctorID: _appointmentdata.doctorID,
          doctorImage: _appointmentdata.doctorImage,
          doctorName: _appointmentdata.doctorName,
          timestamp: _appointmentdata.timestamp,
          id: _appointmentdata.id,
          prescription: _newPrescriptionList);

      setState(() => _appointmentdata = _updatedData);
    }
  }

  void _addMedicine(context) {
    showModalBottomSheet(
        isScrollControlled: false,
        context: context,
        builder: (_) {
          final _courseDaysItems = <DropdownMenuItem>[];
          final _dosagePerDayItems = <DropdownMenuItem>[];

          _courseDaysList.forEach((e) {
            _courseDaysItems.add(DropdownMenuItem(
                value: e,
                child: Text(e > 1 ? '$e days' : '$e day',
                    style: const TextStyle(fontSize: 14))));
          });

          _dosagePerDayList.forEach((e) {
            _dosagePerDayItems.add(DropdownMenuItem(
                value: e,
                child: Text('$e /day', style: const TextStyle(fontSize: 14))));
          });
          return ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: getContextHeight(context) * 0),
            child: Container(
                padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: isKeyboardVisible(context) ? 0 : 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add to prescription',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 32),
                      TextField(
                        autofocus: false,
                        controller: _medicineController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: CodeRedColors.primary2),
                                borderRadius: BorderRadius.circular(5)),
                            hintText: 'Medicine Name'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: CodeRedColors.primary2),
                                        borderRadius: BorderRadius.circular(5)),
                                    hintText: 'Course Duration'),
                                value: _courseDuration,
                                onChanged: (e) {
                                  print(e);
                                  setState(_courseDuration = e);
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                items: _courseDaysItems),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: CodeRedColors.primary2),
                                        borderRadius: BorderRadius.circular(5)),
                                    hintText: 'Dosage'),
                                value: _dosagePerDay,
                                onChanged: (e) {
                                  print(e);
                                  setState(_dosagePerDay = e);
                                  // FocusScope.of(context)
                                  //     .requestFocus(new FocusNode());
                                },
                                items: _dosagePerDayItems),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MaterialButton(
                        elevation: 0,
                        color: CodeRedColors.primary2,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        onPressed: () => _addToAppointment(
                          dosage: _dosagePerDay,
                          context: context,
                          course: _courseDuration,
                          medicine: _medicineController.value.text,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text('Add',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18))
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PrescriptionHeader(data: _appointmentdata),
          const SizedBox(height: 16),
          if (widget.userType == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(children: [
                Expanded(
                  child: MaterialButton(
                      color: CodeRedColors.inputFields,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () => _addMedicine(context),
                      child: const Icon(Icons.add, size: 28)),
                )
              ]),
            ),
          Expanded(
              child: SingleChildScrollView(
            child: ListView.builder(
                itemCount: _appointmentdata.prescription?.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) {
                  final _pres = _appointmentdata.prescription[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[200],
                              blurRadius: 8,
                              offset: Offset.zero)
                        ]),
                    margin:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_pres.medicine,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text('for ${_pres.courseDays} days',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: CodeRedColors.secondaryText))
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_pres.dailyDosage.toString(),
                                style: const TextStyle(fontSize: 22)),
                            const Text('dosages/day',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: CodeRedColors.secondaryText))
                          ],
                        )
                      ],
                    ),
                  );
                }),
          ))
        ],
      ),
    );
  }
}

class PrescriptionHeader extends StatelessWidget {
  const PrescriptionHeader({
    Key key,
    @required this.data,
  }) : super(key: key);

  final AppointmentItem data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      decoration: const BoxDecoration(
          color: CodeRedColors.primary2,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(60))),
      width: getContextWidth(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context)),
                    const Text(
                      'Appointment Details',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                          fontSize: 16),
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFFAFAFA), width: 0),
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20)),
                  height: 42,
                  width: 42,
                  margin: const EdgeInsets.only(right: 32),
                  padding: const EdgeInsets.all(0),
                  child: Hero(
                      tag: data.doctorID,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image(
                          image: CachedNetworkImageProvider(data.doctorImage),
                        ),
                      )),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(left: 36, top: 42, bottom: 8),
              child: const Text(
                'Prescription',
                style: TextStyle(fontSize: 36, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}

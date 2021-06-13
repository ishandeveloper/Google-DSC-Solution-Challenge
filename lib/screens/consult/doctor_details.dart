import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/index.dart';
import '../indicator.dart';
import '../../services/index.dart';
import '../../utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'local_widgets/index.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({Key key, @required this.doctor}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  bool _isLoading = false;

  bool _isValid = true;

  int _currentScreenIndex = 0;

  DateTime _selectedDate;

  Timestamp _selectedTimeSlot;

  PageController _pageController;

  Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _paymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _paymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _paymentExternal);

    _pageController = PageController(initialPage: 0);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pageController.addListener(() {
        if (_currentScreenIndex != _pageController.page.round()) {
          setState(() => _currentScreenIndex = _pageController.page.round());
        }
      });
    });
  }

  void _initPayment() {
    final options = {
      'key': CodeRedKeys.razorPay,
      'amount': 1,
      'name': 'Swaasthy Appointment',
      'description': "Your doctor's appointment on Swaasthy",
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('PAYMENT-ERROR: $e');
    }
  }

  void _paymentExternal() {
    print('Payment External');
  }

  void _paymentError() {
    Navigator.pop(context);
    displaySnackbar(context, 'Your transaction has failed. Please try again');
  }

  void _paymentSuccess() async {
    await ConsultHelper.createAppointment(
      userID: user.uid,
      username: user.username,
      userImage: user.photoURL ??
          'https://api.hello-avatar.com/adorables/ishandeveloper',
      doctorID: widget.doctor.uid,
      doctorName: widget.doctor.name,
      doctorImage: widget.doctor.image,
      timestamp: _selectedTimeSlot,
      date: _selectedDate,
    ).then((value) => print('BOOKED : ${value.toString()}'));

    Navigator.pushReplacementNamed(context, '/home');
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _pageController.dispose();
    super.dispose();
  }

  void _initBooking(context) async {
    showModalBottomSheet(
        isScrollControlled: false,
        context: context,
        builder: (_) {
          return Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr. ${widget.doctor.name}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                    )),
                const SizedBox(height: 4),
                const Text('Appointment details',
                    style: TextStyle(
                      fontSize: 14,
                      color: CodeRedColors.secondaryText,
                      fontFamily: 'ProductSans',
                    )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${timeFormatter(_selectedTimeSlot.toDate())}',
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                    const Text(' on ',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )),
                    Text('${dateFormatter(_selectedDate)}',
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('₹10.00 INR',
                    style: TextStyle(
                      color: CodeRedColors.primary2,
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    )),
                const SizedBox(height: 16),
                SlideAction(
                  sliderRotate: false,
                  animationDuration: const Duration(milliseconds: 500),
                  onSubmit: () => _swipeToConfirm(),
                  height: 58,
                  sliderButtonIcon: Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/icons/gpay.png'))),
                  ),
                  sliderButtonIconPadding: 2,
                  sliderButtonIconSize: 18,
                  textStyle: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 18,
                      color: Colors.white),
                  text: 'Pay with Google Pay',
                  innerColor: Colors.white,
                  outerColor: CodeRedColors.primary2,
                ),
                const SizedBox(height: 16)
              ],
            ),
          );
        });
  }

  // Future<dynamic> _initiateTransaction() async {

  // }

  void _swipeToConfirm() async {
    _initPayment();
    // await ConsultHelper.createAppointment(
    //   userID: "qUOmsgFAwKPHaBSAWTnLah7sjMd2",
    //   username: 'Himanshu Sharma',
    //   userImage: "https://avatars.githubusercontent.com/u/54989142?v=4",
    //   doctorID: widget.doctor.uid,
    //   doctorName: widget.doctor.name,
    //   doctorImage: widget.doctor.image,
    //   timestamp: _selectedTimeSlot,
    //   date: _selectedDate,
    // ).then((value) => print("BOOKED : ${value.toString()}"));

    // Navigator.pushReplacementNamed(context, '/home');
    // HapticFeedback.heavyImpact();

    // FAILED PAYMENT
    // Navigator.pop(context);
    // displaySnackbar(
    //     context, "Your transaction has failed. Please try again");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: Container(
          color: Colors.transparent,
          child: MaterialButton(
            color: (_isLoading || !_isValid)
                ? Colors.grey[400]
                : CodeRedColors.primary2,
            padding: const EdgeInsets.symmetric(vertical: 18),
            onPressed: () => _isLoading
                ? null
                : _currentScreenIndex == 0
                    ? _bookAppointment(context)
                    : _initBooking(context),
            child: _isLoading
                ? Container(
                    height: 22,
                    padding: const EdgeInsets.all(2),
                    width: 22,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))
                : Text(
                    _currentScreenIndex == 0
                        ? 'Book your appointment'
                        : 'Confirm booking',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'ProductSans'),
                  ),
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_titleSection(), _detailsContentBuilder()],
      ),
    );
  }

  void _bookAppointment(context) async {
    setState(() {
      _isLoading = true;
      // Initial data for second page is invalid
      _isValid = false;
    });

    // Mimick a database call
    Future.delayed(const Duration(milliseconds: 800), () {
      _pageController.animateToPage(1,
          duration: const Duration(milliseconds: 250), curve: Curves.easeIn);

      setState(() {
        _isLoading = false;
      });
    });
  }

  void _checkValidation() {
    if (_selectedDate != null && _selectedTimeSlot != null)
      setState(() => _isValid = true);
  }

  Widget _detailsContentBuilder() {
    return Expanded(
        child: PageView(
      physics: const NeverScrollableScrollPhysics(),
      allowImplicitScrolling: false,
      controller: _pageController,
      children: [
        _doctorDetailsContainer(),
        _bookingSlotsContainer(
            timeslots: widget.doctor.timeslots,
            dates: List<DateTime>.generate(7, (iterator) {
              final _ = DateTime.now();

              return DateTime(_.year, _.month, _.day + iterator, 0, 0, 0);
            }))
      ],
    ));
  }

  Widget _doctorDetailsContainer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr.' + widget.doctor.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      CustomIcons.pin_location,
                      size: 14,
                      color: CodeRedColors.icon,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      widget.doctor.details.location,
                      style: const TextStyle(
                        color: CodeRedColors.icon,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9EA),
                    border:
                        Border.all(color: const Color(0xFFFFEDBE), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.doctor.type + ' Specialist',
                    style: const TextStyle(
                      color: Color(0xFFFFBF11),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Text(
                  widget.doctor.details.description,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                SizedBox(
                  height: 91,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DetailCell(
                          title: widget.doctor.details.patients.toString(),
                          subTitle: 'Patients'),
                      DetailCell(
                          title: widget.doctor.details.years.toString(),
                          subTitle: 'Exp. Years'),
                      DetailCell(
                          title: widget.doctor.details.rating.toString(),
                          subTitle: 'Rating'),
                    ],
                  ),
                ),
                // SizedBox(
                //   height: 32,
                // ),
                // Text(
                //   'Apart from kidney-related conditions, Dr Ho also offers care and consultation in various medical conditions that are related to kidney disease, such as hypertension, diabetes and vascular diseases.',
                //   style: TextStyle(
                //     color: Color(0xFF9E9E9E),
                //     fontSize: 14,
                //     fontWeight: FontWeight.w300,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingSlotsContainer(
      {List<Timestamp> timeslots, List<DateTime> dates}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================
          // Date Picker Section
          // ========================================
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pick a date',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: List<Widget>.generate(dates.length, (i) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: _selectedDate == dates[i]
                                  ? CodeRedColors.primary2
                                  : Colors.transparent),
                          onPressed: () {
                            setState(() {
                              _selectedDate = dates[i];
                            });
                            _checkValidation();
                          },
                          child: Text(dateFormatter(dates[i]),
                              style: TextStyle(
                                  color: _selectedDate == dates[i]
                                      ? Colors.white
                                      : CodeRedColors.text))),
                    );
                  }),
                )
              ],
            ),
          ),

          // ========================================
          // Time Slots Picker Section
          // ========================================
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose a time slot',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: List<Widget>.generate(timeslots.length, (i) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: _selectedTimeSlot == timeslots[i]
                                  ? CodeRedColors.primary2
                                  : Colors.transparent),
                          onPressed: () {
                            setState(() {
                              _selectedTimeSlot = timeslots[i];
                            });
                            _checkValidation();
                          },
                          child: Text(timeFormatter(timeslots[i].toDate()),
                              style: TextStyle(
                                  color: _selectedTimeSlot == timeslots[i]
                                      ? Colors.white
                                      : CodeRedColors.text))),
                    );
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: CodeRedColors.primary2,
      elevation: 0,
      brightness: Brightness.dark,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(CustomIcons.arrow_left, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Title Section
  Container _titleSection() {
    return Container(
      height: 250,
      color: CodeRedColors.primary2,
      child: Stack(
        children: [
          SizedBox(width: getContextWidth(context), height: 178),
          Positioned(
            right: 64,
            bottom: 0,
            child: SizedBox(
              height: 242,
              child: Hero(
                tag: widget.doctor.uid,
                child: Image(
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.fitHeight,
                  image: CachedNetworkImageProvider(widget.doctor.image),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 30,
              color: const Color(0xFFFAFAFA),
            ),
          ),
          Positioned(
            right: 32,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFBB23),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    widget.doctor.rating.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Icon(
                    CustomIcons.star,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

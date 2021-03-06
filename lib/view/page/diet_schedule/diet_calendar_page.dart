
import 'package:flutter/cupertino.dart';
import 'package:full_feed_app/model/entities/patient.dart';
import 'package:full_feed_app/model/entities/user_session.dart';
import 'package:full_feed_app/providers/diet_provider.dart';
import 'package:flutter/material.dart';
import 'package:full_feed_app/util/colors.dart';
import 'package:full_feed_app/view_model/diet_view_model.dart';
import 'package:full_feed_app/view_model/patient_view_model.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../view/widget/diet_schedule/message.dart';
import '../../../util/util.dart';
import 'diet_day_detail.dart';

class DietCalendarPage extends StatefulWidget {

  final Patient? patient;
  const DietCalendarPage({Key? key, this.patient}) : super(key: key);

  @override
  _DietCalendarPageState createState() => _DietCalendarPageState();

}

class _DietCalendarPageState extends State<DietCalendarPage> {

  @override
  void initState() {
    if(!isPatient()){
      Provider.of<DietViewModel>(context, listen: false).setPatient(widget.patient!);
    }
    Provider.of<DietViewModel>(context, listen: false).setCalendar();
    super.initState();
  }

  _showDialog(){
    showDialog(
      barrierColor: Colors.white70,
      context: context,
      builder: (BuildContext context) {
        return Message(text: isPatient() ? 'En esa semana no tiene dietas' : 'El paciente no tiene dietas esa semana',
          advice: '',
          yesFunction: (){
          Navigator.pop(context);
        }, noFunction: (){}, options: false,);
      },
    );
  }

  _showNewDietDialog(){
    showDialog(
      barrierColor: Colors.white70,
      context: context,
      builder: (BuildContext context) {
        return Message(text: '¿Seguro desea continuar con la creación de la nueva dieta?',
          advice: 'Recuerde que esta acción inhabilitará la dieta actual por lo que el paciente de marcar todas sus comidas como cumplidas.',
          yesFunction: () async {

          await Provider.of<PatientViewModel>(context, listen: false).generateNewDiet().whenComplete((){
            Navigator.pop(context);
          });
        }, noFunction: (){ Navigator.pop(context); }, options: true,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: ListView(
        children: [
          SfDateRangePicker(
            controller: Provider.of<DietViewModel>(context, listen: false).getController(),
            onSelectionChanged: Provider.of<DietViewModel>(context, listen: false).getWeek,
            showNavigationArrow: false,
            headerStyle: const DateRangePickerHeaderStyle(textStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
            view: DateRangePickerView.month,
            monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: isPatient() ? UserSession().firstDayOfWeek : widget.patient!.firstDayOfWeek!, numberOfWeeksInView: 6, showTrailingAndLeadingDates: true, enableSwipeSelection: false),
            selectionMode: DateRangePickerSelectionMode.range,
            selectionTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
            startRangeSelectionColor: primaryColor,
            endRangeSelectionColor: primaryColor,
            rangeSelectionColor: primaryColor,
            rangeTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
            selectionRadius: 50.0,
            todayHighlightColor: primaryColor,
            selectionShape: DateRangePickerSelectionShape.rectangle,
          ),
          Padding(
              padding: EdgeInsets.only(top: size.height/10),
              child: Row(
                mainAxisAlignment: isPatient() ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
                children: [
                  Visibility(
                    visible: !isPatient(),
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                  stops: [0.05, 1]
                              )
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              _showNewDietDialog();
                            },
                            child: Icon(CupertinoIcons.add_circled, color: Colors.white, size: size.height/20,),
                            style: ElevatedButton.styleFrom(
                              maximumSize: const Size( 200,  200),
                              elevation: 0,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                              primary: Colors.transparent, // <-- Button color
                              onPrimary: Colors.transparent, // <-- Splash color
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('Actualizar dieta', style: TextStyle(fontSize: 12),)
                      ],
                    )
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                stops: [0.05, 1]
                            )
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            Provider.of<DietViewModel>(context, listen: false).getDays();
                            if(isPatient()){
                              await Provider.of<DietViewModel>(context, listen: false).getWeekDietMeals().whenComplete((){
                                Provider.of<DietViewModel>(context, listen: false).initWeekMealList().then((response){
                                  if(response){
                                    Provider.of<DietProvider>(context, listen: false).setDayDetailPresenter(0, context);
                                    Navigator.push(context, PageTransition(
                                        duration: const Duration(milliseconds: 200),
                                        reverseDuration: const Duration(milliseconds: 200),
                                        type: PageTransitionType.rightToLeft,
                                        child: const DietDayDetail(fromRegister: false,)
                                    ));
                                  }
                                  else{
                                    _showDialog();
                                  }
                                });
                              });
                            }
                            else{
                              await Provider.of<DietViewModel>(context, listen: false).getWeekDietMealsByPatient(Provider.of<PatientViewModel>(context, listen: false).getPatientSelected()).whenComplete((){
                                Provider.of<DietViewModel>(context, listen: false).initWeekMealList().then((response){
                                  if(response){
                                    Provider.of<DietProvider>(context, listen: false).setDayDetailPresenter(0, context);
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DietDayDetail(fromRegister: false,)),);
                                  }
                                  else{
                                    _showDialog();
                                  }
                                });
                              });
                            }
                          },
                          child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: size.height/20,),
                          style: ElevatedButton.styleFrom(
                            maximumSize: const Size( 200,  200),
                            elevation: 0,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            primary: Colors.transparent, // <-- Button color
                            onPrimary: Colors.transparent, // <-- Splash color
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text('Revisar dieta', style: TextStyle(fontSize: 12))
                    ],
                  )
                ],
              )
          )
        ],
      ),
    );
  }
}

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart';

/// PhoneLogin screen allows the user to log in using their phone number.
class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  // Form keys for validation
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  // Controllers to handle input from TextFields
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to adapt layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String countryCode = "+91";

    void handleOtpSubmit(String userId, BuildContext context) {
      if (_formKey1.currentState!.validate()) {
        loginWithOtp(otp: _otpController.text, userId: userId).then((value) {
          if (value) {
            // setting phone number and user Id in provider, saving details
            Provider.of<UserDataProvider>(context, listen: false)
                .setUserId(userId);
            Provider.of<UserDataProvider>(context, listen: false)
                .setPhone(countryCode + _phoneNumberController.text);
            Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false,
                arguments: {"title": "add"});
          }
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Login Failed")));
      }
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image section at the top
              Expanded(
                child: Image.asset(
                  'assets/chat.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(0.04 * screenWidth),
                child: Column(
                  children: [
                    // Welcome message
                    const Text(
                      "Welcome to FastChat 👋",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Phone number input field
                    Form(
                      key: _formKey,
                      child: SizedBox(
                        width: double.infinity,
                        height: screenWidth * 0.22,
                        child: TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.length != 10) {
                              return "Invalid phone number";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Enter your Phone number",
                            prefixIcon: CountryCodePicker(
                              onChanged: (value) {
                                print(value.dialCode);
                                countryCode = value.dialCode!;
                              },
                              initialSelection: "IN",
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Send OTP button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createPhoneSession(
                                    phone: countryCode +
                                        _phoneNumberController.text)
                                .then((value) {
                              // value here is the userId of the user
                              // createPhoneSession return userId for user
                              if (value != "login_error") {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text("OTP Verification"),
                                          content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text("Enter 6 digit OTP"),
                                              const SizedBox(
                                                height: 12,
                                              ),
                                              Form(
                                                key: _formKey1,
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  controller: _otpController,
                                                  validator: (value) {
                                                    if (value!.length != 6) {
                                                      return "Invalid OTP";
                                                    }
                                                    return null;
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: "Enter the OTP",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  handleOtpSubmit(
                                                      value, context);
                                                },
                                                child: const Text("Submit"))
                                          ],
                                        ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Failed to send OTP")));
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Send OTP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_picture_page.dart';

class personal_info_screen extends StatefulWidget {
  final String email;
  final String password;

  personal_info_screen({super.key, required this.email, required this.password});

  @override
  State<personal_info_screen> createState() => _personal_info_screenState();
}

class _personal_info_screenState extends State<personal_info_screen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _jobController = TextEditingController();

  String? _selectedCountry;
  String? _selectedGender;
  List<String> _selectedInterests = [];

  bool _isCheckingUsername = false;
  String? _usernameError;

  final themeGreen = const Color(0xFF10B981);

  final List<String> _countries = [
    'United States', 'Canada', 'United Kingdom', 'Germany', 'France', 'India', 'Egypt',
    'Japan', 'Australia', 'Brazil', 'Mexico', 'South Korea', 'Italy', 'Spain', 'Saudi Arabia',
    'United Arab Emirates', 'Turkey', 'South Africa', 'Russia', 'Netherlands'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _interests = [
    'Sports', 'Coding', 'Arts', 'Science', 'Business', 'Literature'
  ];

  Future<void> _checkUsernameUnique(String username) async {
    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.trim())
        .limit(1)
        .get();

    setState(() {
      _isCheckingUsername = false;
      _usernameError = result.docs.isNotEmpty ? 'Username is already taken' : null;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: themeGreen),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Tell us about yourself',
                style: TextStyle(fontSize: 28, fontFamily: 'Dosis',fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First name',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                  hintText: 'Enter your First Name',
                  filled: true,
                  fillColor: Color(0xFFE9FBF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE9FBF4), width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Dosis',
                ),

              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last name',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                  hintText: 'Enter your Last Name',
                  filled: true,
                  fillColor: Color(0xFFE9FBF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE9FBF4), width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Dosis',
                ),

              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(

                  labelText: 'Username',
                  errorText: _usernameError,
                  prefixIcon: Icon(Icons.alternate_email,color: themeGreen,),
                  suffixIcon: _isCheckingUsername
                      ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : (_usernameError == null &&
                      _usernameController.text.trim().length >= 3)
                      ? const Icon(Icons.check, color: Color(0xFF10B981))
                      : null,
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),

                  filled: true,
                  fillColor: Color(0xFFE9FBF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Dosis',
                ),
                onChanged: (value) {
                  if (value.trim().length >= 3) {
                    _checkUsernameUnique(value);
                  } else {
                    setState(() => _usernameError = 'Username too short');
                  }
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _birthdateController,
                decoration: InputDecoration(
                  labelText: 'Birthdate [YYYY-MM-DD]',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                  hintText: 'Enter your birthdate',
                  prefixIcon: Icon(Icons.calendar_month,color: themeGreen,),
                  filled: true,
                  fillColor: Color(0xFFE9FBF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE9FBF4), width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Dosis',
                ),

              ),

              const SizedBox(height: 16),


              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag,color: Color(0xFF10B981),),
                    labelText: 'Country',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontFamily: 'Inter',
                    ),
                    filled: true,
                    fillColor: Color(0xFFE9FBF4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFFE9FBF4), width: 2),
                    ),
                ),
                items: _countries.map((country) {

                  return DropdownMenuItem(value: country, child: Text(country,style: TextStyle(color: themeGreen),));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCountry = value),
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person,color: Color(0xFF10B981),),
                  labelText: 'Gender',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                  filled: true,
                  fillColor: Color(0xFFE9FBF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFFE9FBF4), width: 2),
                  ),),
                items: _genders.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender,style: TextStyle(color: themeGreen),));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jobController,
                decoration: InputDecoration(
                  labelText: 'Job',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                  prefixIcon: Icon(Icons.work,color: themeGreen,),
                  filled: true,
                  fillColor: Color(0xFFE9FBF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE9FBF4), width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Dosis',
                ),

              ),
              const SizedBox(height: 16),
              const Text('Interests:', style: TextStyle(fontSize: 16, fontFamily: 'Dosis')),
              Wrap(
                spacing: 8.0,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(
                      interest,
                      style: TextStyle(
                        fontFamily: 'Dosis',
                        color: isSelected ? themeGreen : themeGreen,
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFE9FBF4),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _selectedInterests.add(interest)
                            : _selectedInterests.remove(interest);
                      });
                    },
                  );
                }).toList(),
              ),


              const SizedBox(height: 24),
              Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _usernameError == null
                       ) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => profile_picture_page(
                            email: widget.email,
                            password: widget.password,
                            firstName: _firstNameController.text.trim(),
                            lastName: _lastNameController.text.trim(),
                            username: _usernameController.text.trim(),
                            birthdate: _birthdateController.text.trim(),
                            country: _selectedCountry,
                            gender: _selectedGender,
                            job: _jobController.text.trim(),
                            interests: _selectedInterests,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(

                    backgroundColor: themeGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Next', style: TextStyle(fontSize: 20,color: Color(0xFFFFFFFF),fontFamily: 'Dosis')),
                      SizedBox(width: 3),
                    ],
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

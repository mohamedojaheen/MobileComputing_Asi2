import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_course_screen.dart';
import 'login_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  Future<void> _enrollInCourse(
      BuildContext context, String courseId, String courseName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Add enrollment to the course document
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('enrollments')
          .doc(userId)
          .set({
        'userId': userId,
        'enrolledAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully enrolled in $courseName!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error enrolling in course')),
        );
      }
    }
  }

  Future<bool> _isEnrolled(String courseId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('enrollments')
        .doc(userId)
        .get();

    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Courses'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading courses'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No courses available. Add a course to get started!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final course = snapshot.data!.docs[index];
              final courseId = course.id;
              final courseName = course['name'];
              final courseCode = course['code'];
              final instructor = course['instructor'];

              return FutureBuilder<bool>(
                future: _isEnrolled(courseId),
                builder: (context, enrollSnapshot) {
                  final isEnrolled = enrollSnapshot.data ?? false;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          courseCode.substring(0, 2).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        courseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('$courseCode - $instructor'),
                      trailing: isEnrolled
                          ? const Chip(
                              label: Text('Enrolled'),
                              backgroundColor: Colors.green,
                              labelStyle: TextStyle(color: Colors.white),
                            )
                          : ElevatedButton(
                              onPressed: () =>
                                  _enrollInCourse(context, courseId, courseName),
                              child: const Text('Enroll'),
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
pragma solidity ^0.8.0;

contract StudentRegistry {

    struct Student {
        uint256 id;
        string name;
        uint8 age;
        string course;
        uint8 marks;
    }

    Student[] private students;
    mapping(uint256 => bool) private registeredIds;
    mapping(uint256 => uint256) private studentIdx;

    // constants.
    uint8 private constant MIN_AGE = 3;
    uint8 private constant MAX_AGE = 100;
    uint8 private constant MAX_MARKS = 100;
    
    // events.
    event StudentRegistered(uint256 id, string name, uint8 age, string course, uint8 marks);
    event MarksUpdated(uint256 id, uint8 oldMarks, uint8 newMarks);
    event StudentRemoved(uint256 id);

    // functions.

        // student registration.
    function registerStudent(uint256 _id, string memory _name, uint8 _age, string memory _course, uint8 _marks) external  {
        require(_id > 0, "Id should be greater than zero");
        require(!registeredIds[_id], "Student with this id already exists");
        require(_age >= MIN_AGE && _age <= MAX_AGE, "Age out of valid range");
        require(_marks >= 0 && _marks <= MAX_MARKS, "Marks should be in range 0..100");
        require(bytes(_name).length > 0, "Student name cannot be empty");
        require(bytes(_course).length > 0, "Course name cannot be empty");

        students.push(
            Student({
                id: _id,
                name: _name,
                age: _age,
                course: _course,
                marks: _marks
            })
        );

        registeredIds[_id] = true;
        studentIdx[_id] = students.length - 1;

        emit StudentRegistered(_id, _name, _age, _course, _marks);
    }

        // update marks.
    function updateMarks(uint256 _id, uint8 _newMarks) external {
        require(_id > 0, "Id should be greater than zero");
        require(_newMarks >= 0 && _newMarks <= MAX_MARKS, "Marks should in the range 0..100");
        require(registeredIds[_id], "Student not registered");

        Student storage student = students[studentIdx[_id]];
        uint8 oldMarks = student.marks;
        student.marks = _newMarks;

        emit MarksUpdated(_id, oldMarks, _newMarks);
    }

        // remove student.
    function removeStudent(uint256 _id) external {
        require(_id > 0, "Id should be greater than zero");
        require(registeredIds[_id], "Student not registered");

        uint256 idx = studentIdx[_id];
        uint256 lastStudentIdx = students.length - 1;
        
        if(idx != lastStudentIdx) {
            Student storage lastStudent = students[lastStudentIdx];
            students[idx] = lastStudent;
            studentIdx[lastStudent.id] = idx;
        }

        students.pop();
        delete studentIdx[_id];
        delete registeredIds[_id];

        emit StudentRemoved(_id);
    }

        // getting student details.
    function getStudent(uint256 _id) external view returns (
        uint256 id, 
        string memory name, 
        uint8 age, 
        string memory course, 
        uint8 marks
    ) {
        require(_id > 0, "Id should be greater than zero");
        require(registeredIds[_id], "Student not registered");

        Student storage student = students[studentIdx[_id]];

        return (student.id, student.name, student.age, student.course, student.marks);
    }

        // getting all students with details.
    function getAllStudents() external view returns (
        uint256[] memory ids, 
        string[] memory names, 
        uint8[] memory ages, 
        string[] memory courses, 
        uint8[] memory markList
    ) {
        uint256 length = students.length;

        ids = new uint256[](length);
        names = new string[](length);
        ages = new uint8[](length);
        courses = new string[](length);
        markList = new uint8[](length);

        for(uint256 i = 0; i < length; i++) {
            Student storage s = students[i];
            ids[i] = s.id;
            names[i] = s.name;
            ages[i] = s.age;
            courses[i] = s.course;
            markList[i] = s.marks;
        }
    }
}

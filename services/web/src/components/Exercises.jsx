import React, { Component } from 'react';
import axios from 'axios';

import Exercise from './Exercise'

class Exercises extends Component {
    constructor (props) {
        super(props)
        this.state = {
            exercises: [],
            editor: {
                value: '# Enter your code here.',
                button: { isDisalbed: false, },
                showGrading: false,
                showCorrect: false,
                showIncorrect: false
            }
        };
        this.onChange = this.onChange.bind(this);
        this.submitExercise = this.submitExercise.bind(this);
    };

    onChange(value) {
        const newState = this.state.editor;
        newState.value = value;
        this.setState(newState);
    };

    getExercises() {
        axios.get(`${process.env.REACT_APP_EXERCISES_SERVICE_URL}/exercises`)
        .then((res) => { this.setState({ exercises: res.data.data.exercises }); })
        .catch((err) => { console.log(err); });
    };

    submitExercise(event) {
        event.preventDefault();
        const newState = this.state.editor;
        newState.showGrading = true;
        newState.showCorrect = false;
        newState.showIncorrect = false;
        newState.button.isDisabled = true;
        this.setState(newState);
        const data = { answer: this.state.editor.value };
        const url = process.env.REACT_APP_API_GATEWAY_URL;
        axios.post(url, data)
        .then((res) => {
            newState.showGrading = false
            newState.button.isDisabled = false
            if (res.data) { newState.showCorrect = true };
            if (!res.data) { newState.showIncorrect = true };
            this.setState(newState);
        })
        .catch((err) => {
            newState.showGrading = false
            newState.button.isDisabled = false
            console.log(err);
        })
    };

    componentDidMount() {
        this.getExercises();
    };

    render() {
        return (
            <div>
                <h1 className="title is-1">Exercises</h1>
                <hr/><br/>
                {!this.props.isAuthenticated &&
                    <div className="notification is-warning">
                    <span>Please log in to submit an exercise.</span>
                    </div>
                }
                {this.state.exercises.length > 0 &&
                    <Exercise
                    exercise={this.state.exercises[0]}
                    editor={this.state.editor}
                    isAuthenticated={this.props.isAuthenticated}
                    onChange={this.onChange}
                    submitExercise={this.submitExercise}
                    />
                }
            </div>
        )
    };
};

export default Exercises;
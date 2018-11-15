import React, { Component } from 'react';
import AceEditor from 'react-ace';
import 'brace/mode/python';
import 'brace/theme/solarized_dark';

class Exercises extends Component {
    constructor (props) {
        super(props)
        this.state = {
            exercises: []
        };
    };

    getExercises() {
        const exercises = [
            {
                id: 0,
                body: `Define a function called sum that takes 
                two integers as arguments and returns their sum.`
            },
            {
                id: 1,
                body: `Define a function called reverse that takes a string 
                as an argument and returns the string in reversed order.`
            },
            {
                id: 2,
                body: `Define a function called factorial that takes a random 
                number as an argument and returns the factorial of that given number.`
            }
        ];
        this.setState({ exercises: exercises });
    };

    componentDidMount() {
        this.getExercises();
    }

    render() {
        return (
            <div>
                <h1 className="title is-1">Exercises</h1>
                <hr/><br/>
                {this.state.exercises.length &&
                    <div key={this.state.exercises[0].id}>
                        <h5 className="title is-5">{this.state.exercises[0].body}</h5>
                        <AceEditor mode="python"
                            theme="solarized_dark"
                            name={(this.state.exercises[0].id).toString()}
                            onLoad={this.onLoad}
                            fontSize={14}
                            height={'175px'}
                            showPrintMargin={true}
                            showGutter={true}
                            highlightActiveLine={true}
                            value={'# Enter your code here.'}
                            style={{
                                marginBottom: '10px'
                            }}
                            editorProps={{
                                $blockScrolling: Infinity
                            }}
                        />
                        <button className="button is-primary">Run Code</button>
                        <hr/><br/>
                    </div>
                }
            </div>
        )
    };
};

export default Exercises;
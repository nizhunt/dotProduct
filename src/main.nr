// main function is the entry point to the noir program
// we take three inputs, 'x' and 'y' and 'solution'
// Field is a default numeric datatype in noir
// inputs x and y are array of length 2 and type Field ie. [Field; 2]
// input 'solution' is a Field
fn main(x : [Field; 2], y : pub [Field; 2], solution: Field) {

    // calculate the dotProduct of x and y and save it into 'out'
    let out = dotProduct(x,y);

    // make sure out is equal to the solution provided by the student
    assert (out == solution);
}

// take x and y as inputs and return a Field output
fn dotProduct(x : [Field; 2], y : [Field; 2]) -> Field {
    // 'mut' is used to mark the "out" veritable mutable
    let mut out = 0;

    // for loop syntax:
    // for variable in lower_bound_number..upper_bound_number
    // lower bound is inclusive
    // upper bound is exclusive
    for i in 0..2 {
        out = out + x[i] * y[i];
    }

    // the last expression in a function's body is returned
    out
}
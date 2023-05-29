# A Practice Guide to Implementing ZK Proof Using Noir-Lang

## Introduction

This is a beginner level introduction article for those who want to understand Zero Knowledge Proofs by building a small project without getting into the complected math behind it.

This article assumes you know basic bash operations, have a basic understanding of solidity and have used RemixIDE in the past to build and deploy smart contracts, that's it!

Let's go!!

Assume a math teacher has taught matrix multiplication in his class and he wants to check if all his students are able to find the dot product of a simple 1x2 matrix.

## Problem

Take any two one by two matrices, x and y and find their dot product.

```rust
Student 1:
x = [2,3]
y = [1,2]
solution = 8 ✅
// (2*1 + 3*2) = 8

Student 2:
x = [1,2]
y = [3,4]
solution = 12 ❌
// (2*1 + 3*2) = 11
```

But the teacher doesn't want to check each solution by his own, so he appoints a student to verify everyone's calculation.

The math teacher is a ZKP buff and want's to undertake the task using Zero Knowledge Proofs such that:

- The verifier student should never ask for the actual matrices x and y or the solution from any student.
- All that the verifier can ask for is a `proof` which can not be calculated back into the original values of x, y and the solution
- From this proof, the verifier should be able to figure out if the calculation is correct or not.

## Setup

We'll be using [Noir-lang](https://noir-lang.org/) for the generation and verification of the proofs. Lets start with the installation

1. Install Noir and Nargo from your bash terminal

   ```bash
   curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
   ```

   Close the terminal, open another one, and run

   ```bash
   noirup
   ```

   Done, you should have the latest version working. You can check with `nargo --version`.

   > Check [the docs](https://noir-lang.org/getting_started/nargo_installation) for other ways of installation

2. Create a directory and cd into it

   ```bash
   mkdir ~/mathHomeWork
   cd ~/mathHomeWork
   ```

3. Create a new nargo project

   ```bash
   nargo new dotProduct
   ```

   Similar to Rust, the folder houses src/main.nr and Nargo.toml that contains the source code and environmental options of your Noir program respectively.

Voila, this is all the setup we need to get going!!

## Math Teacher

For now, take the role of the math teacher. You have to formulate the [problem statement](#problem) into a ZK Circuit.

Go to the src folder. This is where we will write the logic for the circuit. Replace the content of the [main.nr](./src/main.nr) file with

```rust
// main function is the entry point to the noir program
// we take three inputs, 'x' and 'y' and 'solution'
// Field is a default numeric datatype in noir
// inputs x and y are array of length 2 and type Field ie. [Field; 2]
// input 'solution' is a Field
fn main(x : [Field; 2], y : [Field; 2], solution: Field) {

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
```

cd into the `dotProduct` directory from your terminal and run `nargo check`. Expect the following output

```bash
Constraint system successfully built!
```

That's it, the teacher's job is done. Good job!

## Students

A student's job is to come up with two 1x2 matrices and it's dot product, and generate a proof to provide to the verifier. This repository is handed over to all the students by the math teacher.

### Student1

Lets say student1 comes up with this

```rust
Student1:
x = [2,3]
y = [1,2]
solution = 8 ✅
// (2*1 + 3*2) = 8
```

Let's get started:

- Go to [Prover.toml](./Prover.toml) and put the homework down as shown

  ```rust
  x = ["2", "3"]
  y = ["1", "2"]
  solution = "8"
  ```

- To generate the proof, run `nargo prove student1`
- It might take a while if you are doing this for the first time as nargo will download the SRS
- Your proof file is generated in the proofs directory with name [student1.proof](./proofs/student1.proof)

### Student2

Student2 comes up with an incorrect calculation:

```rust
Student 2:
x = [1,2]
y = [3,4]
solution = 12 ❌
// (2*1 + 3*2) = 11
```

Go back to [Prover.toml](./Prover.toml) and put the new inputs down

```rust
x = ["1", "2"]
y = ["3", "4"]
solution = "12"
```

To generate the proof, run `nargo prove student2`

You will be prompted with

`Error: could not satisfy all constraints`

You can see, its not possible to generate a proof if all the assertions defined in the circuit do not satisfy.

Lets correct the inputs in the [Prover.toml](./Prover.toml) file

```rust
x = ["1", "2"]
y = ["3", "4"]
solution = "11"
```

Now try again to generate the proof, run `nargo prove student2`

Proof file for Student2 will be generated in the proofs directory with name [student2.proof](./proofs/student2.proof)

## Verifier

The verifier will receive the main.nr file generated by the teacher and all of the proofs generated by the students but not actual answers by the students.

So if you want you can go on and delete the Prover.toml file to simulate the repository of the Verifier

In the terminal run the verification

`nargo verify student1.proof`

If nothing returns, that means the proof is valid, try it with student2's proof as well

`nargo verify student2.proof`

### What happens if a student tries to fake a proof?

Let's say a student doesn't do the homework and generates a proof file made up of random values. To simulate this, go to the [student2.proof](./proofs/student2.proof) file and change a random character/digit and try to verify

`nargo verify student2.proof`

You will be meet with an error! No one can fool the verifier.

Voila! We have successfully implemented Zero Knowledge Proof in our homework checking system.

## What did we achieve?

The students are now able to prove to both the teacher and the verifier that they have successfully done the homework of solving a dot product on 1x2 matrix without actually disclosing either the matrices they chose to preform it on or the result they obtained. Isn't it fabulous?

Now I know not many students in the world are hell-bent to hide the details of their homework from their teacher. But just imagine how many use-cases this tech can prove useful in!

## Verification through a Smart Contract

Hmm, with the success of the ZK verification, the teacher is very happy and he wants to take things up a notch. He has decided he will eliminate the need of a verifier by deploying the verifier logic on a smart contract. And while at it, he has also decided to award each student with an appreciation NFT if they have a valid proof of homework.

Let's get going with this feat!

In your terminal, enter:

`nargo codegen-verifier`

This will create a new folder called `contract` with a file called [plonk_vk.sol](./contract/plonk_vk.sol) inside it.

This contract will be used to verify the proofs for our homeWork circuit. The working of the contract is beyond the purview of this humble article.

For now, all you have to know is that we'll be calling the `verify(bytes calldata _proof, bytes32[] calldata _publicInputs)` external function from this contract that takes the proof and an array of publicInputs and returns a bool, which will be true if the proof is valid.

What we are about to do is to create our ERC721 NFT contract and make it deploy an instance of `plonk_vk.sol` contract at the time of construction. Then use the `verify()` function of the `plonk_vk.sol` contract from within the NFT contract before minting an NFT.

Open remix and save the `plonk_vk.sol` contract in the IDE. Create another file in the IDE called `homeWorkNFT.sol` and paste the following code:

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {UltraVerifier} from "./plonk_vk.sol";

contract HomeWork is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    UltraVerifier verifier;

    error StudentNotVerified();

    constructor() ERC721("HomeWork", "HW") {
        verifier = new UltraVerifier();
    }

    // `safeMint` accepts the proof and mints an NFT for the sender if the proof is valid
    function safeMint(
        bytes calldata _proof
    ) public {
        bytes32[] memory emptyBytes32Array;

        // verify function accepts a proof and an array of return parameters,
        // as our circuit does not have any public input, we'll pass an empty array
        try verifier.verify(_proof, emptyBytes32Array ) returns (bool verified) {
            if (!verified) {
                revert StudentNotVerified();
            }
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);
        } catch {
            revert StudentNotVerified();
        }
    }
}
```

Deploy this contract, copy the data from student1.proof, go to the safeMint() function of the deployed contract, paste the copied data and send the transaction.

> Don't forget to append `0x` before the proof as the function accepts a bytes input. If proof = `29d5ec...`, the input will be: `0x29d5ec...`

If the proof is valid, you'll be able to mint a HomeWork NFT for yourself.

## Conclusion

We just deployed a smart-contract that can mint NFTs for proofs without exposing any information involved in the generation of the proof!

This was a basic introduction to practical use of ZKPs without dabbling into any of the technicalities (moon math) behind it. I hope this tutorial has inspired you to learn more about ZKPs and explore it's use in your future projects.

# Sample Test Cases <!-- omit in toc -->

The sample test cases in this repository include two TTCN-3 examples. Each test case is explained below, detailing its functionality. The [`MyExample.ttcn`](https://github.com/ifsc-lased/daf-ttcn3-container/blob/en-version/Example/HelloWorld/MyExample.ttcn) file contains these examples:

- **tc_HelloW()**: Sends a `"Hello, world!"` message and sets the verdict to pass if the sending is successful. Here’s the code:

    ```ttcn
    testcase tc_HelloW() runs on MTCType system MTCType
    {
      map(mtc:MyPCO_PT, system:MyPCO_PT);
      MyPCO_PT.send("Hello, world!");
      setverdict(pass);
    }
    ```

- **tc_HelloW2()**: Sends a `"Hello, world!"` message and waits for a specific response using a timer (_TL_T_). The verdict will be pass if the response is `"Hello, TTCN-3!"` within 15 seconds, inconclusive if the timer expires, and fail for any other response. Here’s the code:

    ```ttcn
    testcase tc_HelloW2() runs on MTCType system MTCType
    {
      timer TL_T := 15.0;
      map(mtc:MyPCO_PT, system:MyPCO_PT);
      MyPCO_PT.send("Hello, world!");
      TL_T.start;
      alt {
        [] MyPCO_PT.receive("Hello, TTCN-3!") { TL_T.stop; setverdict(pass); }
        [] TL_T.timeout { setverdict(inconc); }
        [] MyPCO_PT.receive { TL_T.stop; setverdict(fail); }
      }
    }
    ```

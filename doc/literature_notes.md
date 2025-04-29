# Literature Notes and Approximation Strategy

## Chosen Approximation: Approximate Full Adder v1 (AxFA_v1)

The primary approximation technique employed in `approx_compressor_8_2_v1.v` is based on simplifying the logic within the Full Adder (FA) cells used in the compressor's structural tree. Specifically, we use an "Approximate Full Adder version 1" (`approx_full_adder_v1.v`), defined as:

*   **Inputs:** `a`, `b`, `cin`
*   **Outputs:** `sum`, `cout`
*   **Logic:**
    *   `sum = a ^ b ^ cin`  (The sum calculation remains **exact**)
    *   `cout = a & b`       (The carry-out calculation is **approximated**, ignoring the influence of `cin`)

## Rationale

This type of approximation is common in approximate arithmetic circuit design literature. The rationale includes:

*   **Simplicity:** Replacing the standard carry logic `(a & b) | (a & cin) | (b & cin)` with just `a & b` significantly reduces gate count and complexity within each FA.
*   **Carry Chain Impact:** The carry propagation path is often critical for the overall delay and power of arithmetic circuits. Simplifying carry generation can lead to improvements in these metrics.
*   **Error Characteristics:** Ignoring `cin` in the carry calculation introduces errors primarily when `a` or `b` is '0' but `cin` is '1' (and `a` and `b` are not both '1'). The impact of these errors depends on the application's tolerance. The sum bit remains accurate, which helps limit the overall error magnitude in some cases.

## Expected Trade-offs

Compared to the exact compressor built with standard FAs, the compressor using `AxFA_v1` is expected to exhibit:

*   **Lower Area:** Due to simpler logic in each AxFA cell.
*   **Lower Power:** Reduced switching activity and gate count.
*   **Potentially Higher Speed (Lower Delay):** Simplified carry logic might shorten critical paths, although this depends heavily on synthesis optimization.
*   **Introduced Errors:** The `sum[1]` (carry) output of the 8:2 compressor will be inaccurate for certain input combinations, leading to non-zero Error Rate (ER) and Mean Error Distance (MED).

## Alternatives Considered

Other approximation strategies exist for compressors and adders, such as:

*   Different AxFA designs (e.g., approximating the sum bit, using OR gates for carry).
*   Input or output truncation.
*   Using approximate 4:2 compressors as building blocks.
*   Algorithmic error introduction techniques.

The `AxFA_v1` was chosen for this project as a clear and well-understood example of gate-level approximation suitable for demonstrating the design and evaluation flow.

## References

*(Add specific citations here if your work is based on particular papers)*

*   [Example Reference Format] Author(s), "Title of Paper," Journal/Conference Name, Vol. X, No. Y, pp. ZZZ-ZZZ, Year.
*   General principles discussed in surveys on Approximate Computing.

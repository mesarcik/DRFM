# Article Template

Journal article or conference paper, two-column template in IEEE format using the IEEEtran package. Recommended compiler is pdfLaTeX.

Basic global information such as author and title can be changed in the `main.tex` file. The bibliography has been set to adhere to the IEEE standard and BibTeX entries can be placed in the References.bib file.

## Commands

### Figures

Figures can be inserted using the `\Figure` command:

```latex
\Figure[width=1\columnwidth]{Example figure description}{figure_name}
```

This will create a figure with the caption "Example figure description" and a label with name `fig:figure_name`. `figure_name` must be the name of the figure, excluding extension, and should reside in the "figures" folder. The optional parameters that are given are directly passed to the `\includegraphics` command. In other words you can use other parameters such as `scale`, `angle`.

### Tables

You can insert tables using the `\Table` command as demonstrated below:

```latex
\Table{My Informative Table}{|l|c|r|}{ % this format specifies 3 columns with left, center and right alignment
  \textbf{Heading 1} & \textbf{Heading 2} & \textbf{Heading 3}
}{
  Data & 123 & 321 \\
  Data & 456 & 654 \\
  Data & 789 & 987 \\
}{Example}
```

This will create a floating table with the caption "My Informative Table" and a label with name `tab:Example`.

### Listings

You can insert syntax highlighted source code using:

```latex
\begin{lstlisting}[language=Matlab, caption={Code description}, label={lst:example_code}]
# Example code
x = linspace(0, 2*pi, 1000);
y = sin(x);
plot(x, y); grid on;
\end{lstlisting}
```

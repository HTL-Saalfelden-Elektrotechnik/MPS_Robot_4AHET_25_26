# Makefile for MPS Robot Documentation
# Typst document compilation

# Variables
TYPST = typst
SRC_DIR = .
OUT_DIR = build
MAIN_DOC = TCP_Server_Improvement_Concept.typ

# Output formats
PDF = $(OUT_DIR)/TCP_Server_Improvement_Concept.pdf

# Default target
all: pdf

# Create output directory
$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# Compile to PDF
pdf: $(OUT_DIR) $(MAIN_DOC)
	$(TYPST) compile $(MAIN_DOC) $(PDF)

# Watch for changes and recompile
watch: $(OUT_DIR)
	$(TYPST) watch $(MAIN_DOC) $(PDF)

# Clean build artifacts
clean:
	rm -rf $(OUT_DIR)

# Help
help:
	@echo "MPS Robot Documentation Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all     - Build PDF (default)"
	@echo "  pdf     - Compile Typst to PDF"
	@echo "  watch   - Watch for changes and recompile"
	@echo "  clean   - Remove build artifacts"
	@echo "  help    - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - Typst (https://typst.app/)"

.PHONY: all pdf watch clean help

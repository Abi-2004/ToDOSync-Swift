//
//  AddTodoView.swift
//  ToDO
//
//  Created by Abi on 29/5/25.
//

import SwiftUI
import UIKit
import UIKit
import UIKit

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddTodoViewModel
    
    // Capturamos el initialDate en una propiedad local de la vista
    private let dateForHeader: Date

    // MARK: - Inicializadores

    /// Inicializador antiguo (compatibilidad hacia atrás con TodoDataManager)
    init(dataManager: TodoDataManager, initialDate: Date = Date()) {
        // Creamos el repositorio centralizado (puente a la nueva arquitectura)
        let repository = TodoRepository()
        _viewModel = StateObject(
            wrappedValue: AddTodoViewModel(
                repository: repository,
                initialDate: initialDate
            )
        )
        // Guardamos la fecha en la vista
        self.dateForHeader = initialDate
    }

    /// Inicializador MVVM moderno
    init(repository: TodoRepositoryProtocol, initialDate: Date = Date()) {
        _viewModel = StateObject(
            wrappedValue: AddTodoViewModel(
                repository: repository,
                initialDate: initialDate
            )
        )
        // Guardamos la fecha en la vista
        self.dateForHeader = initialDate
    }

    // MARK: - Gradiente según prioridad

    /// Gradiente que varía según la prioridad seleccionada
    private var priorityGradient: LinearGradient {
        let priorityColor = viewModel.selectedPriority.color
        return LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                priorityColor.opacity(0.3),
                priorityColor.opacity(0.5),
                priorityColor.opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Cuerpo de la Vista

    var body: some View {
        ZStack {
            // Fondo degradado que cambia con la prioridad
            priorityGradient
                .ignoresSafeArea(.all)
                .animation(.easeInOut(duration: 0.3), value: viewModel.selectedPriority)

            // NavigationView principal (con fondo transparente)
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Encabezado que muestra la fecha capturada
                        HeaderView(date: dateForHeader)

                        // Sección de formulario con título y descripción
                        FormView(
                            title: $viewModel.title,
                            description: $viewModel.description
                        )

                        // Selector horizontal de categorías
                        CategoryPickerView(
                            selectedCategory: $viewModel.selectedCategory
                        )

                        // Selector horizontal de prioridades
                        PriorityPickerView(
                            selectedPriority: $viewModel.selectedPriority
                        )
                        
                        // Espaciado adicional para el bottom safe area
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom)
                }
                .background(Color.clear)

                // Barra de navegación y botones
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.red)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            viewModel.saveTodo()
                            dismiss()
                        }
                        .disabled(!viewModel.canSave)
                        .foregroundColor(viewModel.canSave ? .blue : .gray)
                        .fontWeight(.semibold)
                    }
                }
            }
            // Hacemos transparente el fondo del NavigationView
            .background(Color.clear)
            .navigationViewStyle(.stack) // Que en iPad también use estilo de pila
        }
    }
}

// MARK: - Subcomponentes Privados

/// Vista de encabezado: "New Task" y fecha formateada
private struct HeaderView: View {
    let date: Date

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("New Task")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(
                        "Creating task for " +
                        "\(date.formatted(.dateTime.weekday(.wide).day().month(.wide)))"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

/// Sección del Form con los campos de título y descripción
private struct FormView: View {
    @Binding var title: String
    @Binding var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Sección de detalles de la tarea
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Details")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Campo para el título de la tarea
                    TextField("Enter task title...", text: $title)
                        .font(.system(size: 16))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                )
                        )

                    // Campo para la descripción opcional
                    TextField(
                        "Add description (optional)",
                        text: $description,
                        axis: .vertical
                    )
                    .font(.system(size: 14))
                    .lineLimit(3...6)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

/// Selector horizontal de categorías
private struct CategoryPickerView: View {
    @Binding var selectedCategory: TodoCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TodoCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                    .opacity(selectedCategory == category ? 1.0 : 0.3)

                                Text(category.rawValue)
                                    .font(
                                        .system(
                                            size: 14,
                                            weight: selectedCategory == category
                                                ? .semibold
                                                : .regular
                                        )
                                    )
                                    .foregroundColor(
                                        selectedCategory == category
                                            ? category.color
                                            : .secondary
                                    )
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        selectedCategory == category
                                            ? category.color.opacity(0.1)
                                            : Color.clear
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedCategory == category
                                                    ? category.color
                                                    : Color(UIColor.systemGray4),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

/// Selector horizontal de prioridades
private struct PriorityPickerView: View {
    @Binding var selectedPriority: TodoPriority

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                ForEach(TodoPriority.allCases, id: \.self) { priority in
                    Button(action: {
                        selectedPriority = priority
                    }) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(priority.color)
                                .frame(width: 10, height: 10)

                            Text(priority.rawValue)
                                .font(
                                    .system(
                                        size: 16,
                                        weight: selectedPriority == priority
                                            ? .semibold
                                            : .regular
                                    )
                                )
                                .foregroundColor(
                                    selectedPriority == priority
                                        ? priority.color
                                        : .primary
                                )
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    selectedPriority == priority
                                        ? priority.color.opacity(0.1)
                                        : Color(UIColor.systemGray6)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            selectedPriority == priority
                                                ? priority.color
                                                : Color(UIColor.systemGray4),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Preview

#Preview {
    AddTodoView(repository: TodoRepository())
}

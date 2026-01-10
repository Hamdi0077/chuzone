import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import App from './App';

describe('App Component', () => {
  it('should render the ChuZone heading', () => {
    render(<App />);
    const heading = screen.getByText(/ChuZone - DevOps POC/i);
    expect(heading).toBeInTheDocument();
  });

  it('should display version 1.0.0', () => {
    render(<App />);
    const version = screen.getByText(/Version 1.0.0/i);
    expect(version).toBeInTheDocument();
  });

  it('should initialize counter at 0', () => {
    render(<App />);
    const counter = screen.getByTestId('counter-value');
    expect(counter).toHaveTextContent('0');
  });

  it('should increment counter when + button is clicked', async () => {
    const user = userEvent.setup();
    render(<App />);
    
    const incrementButton = screen.getAllByRole('button')[1]; // + button
    await user.click(incrementButton);
    
    const counter = screen.getByTestId('counter-value');
    expect(counter).toHaveTextContent('1');
  });

  it('should decrement counter when - button is clicked', async () => {
    const user = userEvent.setup();
    render(<App />);
    
    const decrementButton = screen.getAllByRole('button')[0]; // - button
    await user.click(decrementButton);
    
    const counter = screen.getByTestId('counter-value');
    expect(counter).toHaveTextContent('-1');
  });
});
